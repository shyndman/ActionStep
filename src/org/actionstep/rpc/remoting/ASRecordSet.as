/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.constants.ASDeliveryMode;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASResponse;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.remoting.ASRemotingService;

/**
 * Supports paging of database records used by remoting.
 *
 * Please note that "fields" and "columns" are used interchangably.
 *
 * For more information on the AMF-RecordSet specification, please see:
 * <a href="http://osflash.org/amf/recordset"/>Open Source Flash - amf:recordset:</a>
 *
 * For more information on how the delivery modes differ, please see
 * <code>ASDeliveryMode</code>
 * @see org.actionstep.constants.ASDeliveryMode;
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.rpc.remoting.ASRecordSet extends NSObject{

  //******************************************************
  //*                 Class members
  //******************************************************

  /**
   * This value will be used when new columns are inserted. It will be appended to
   * existing records stored locally.
   */
  public static var DEFAULT_PAD:Object = "";

  /**
   * The names of the methods that will be invoked when an item has been requested
   * through a server request. Note that they differ from <code>ASPendingCall</code>'s
   * to prevent conflicts.
   */
  public static var DEFAULT_RESULT_METHOD:String = "didGetItemSuccess";
  public static var DEFAULT_FAULT_METHOD:String = "didGetItemFail";

  /**
   * These values specify the bounds of page sizes. Please change them accordingly to
   * optimize performance.
   */
  public static var DEFAULT_MIN_PAGESIZE:Number = 5;
  public static var DEFAULT_MAX_PAGESIZE:Number = 25;

  //******************************************************
  //*                 Member variables
  //******************************************************

  private var m_columns:NSDictionary;
  private var m_rows:NSDictionary;
  private var m_itemId:String;
  private var m_version:Number;
  private var m_cursor:Number;
  private var m_service:ASRemotingService;
  private var m_serviceName:String;
  private var m_length:Number;

  /** Callbacks for use when data has been retrieved */
  private var m_responder:Object;

  private var m_mode:ASDeliveryMode;
  private var m_pageSize:Number;
  private var m_pages:Number;

  private var m_pendingOps:Array;
  private var m_isPending:Boolean;

  //******************************************************
  //*                 Construction
  //******************************************************

  /**
   * Constructs a new record set instance.
   */
  public function ASRecordSet(colNames:Array) {
    m_rows = NSDictionary.dictionary();
    m_itemId = "";

    m_pendingOps = [];
    m_isPending = false;
  }

  /**
   * Be careful when invoking this method, since it will overwrite <code>m_columns</code>,
   * <code>m_rows</code>, and other properties with the values found in the argument.
   *
   * Note also that the method replaces and not insert records.
   *
   * @throws ASInvalidCondition if <code>data</code> is not recognized.
   */
  public function initWithResponseForService(data:Object, service:ASService):ASRecordSet {
    if(!isRecognizedType(data)) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo
      ("ASInvalidCondition", "Unrecognized data type used for initialization");
      trace(e);
      throw e;
    }

    data = data.serverInfo;
    initColumns(Array(data.columnNames));
    m_itemId = String(data.id);
    m_version = Number(data.version);
    m_cursor = Number(data.cursor);
    m_serviceName = String(data.serviceName);
    m_length = Number(data.totalCount);

    if(m_columns.count()>0) {
      var arr:Array = Array(data.initialData);
      var i:Number = arr.length;
      try {
        //replace instead of insert to overwrite null values
        while(i--) {
          replaceRecordAtIndex(arr[i], i);
        }
      } catch (e:NSException) {
        trace(e);
        throw e;
      }
    }

    m_service = ASRemotingService.serviceForNameURL(m_serviceName, service.connection().URL());
    if(m_service==null) {
      m_service = (new ASRemotingService()).initWithNameConnectionTracing(
        m_serviceName, service.connection(), false);
      m_service.setTimeout(service.timeout());
    }

    turnOnOnDemandMode(true);

    return this;
  }

  //******************************************************
  //*               Describing the object
  //******************************************************

  /**
   * Returns a string representation of the object.
   */
  public function description():String {
    var ret:String = "";
    var fields:Array = columnNames().internalList();
    var i:Number = fields.length;

    ret+="localLength:\t"+localLength()+"\n";
    while(i--) {
      ret+=fields[i]+":\t"+valuesForField(fields[i])+"\n";
    }
    return "ASRecordSet(\n"+ret+
    ")";
  }

  //******************************************************
  //*            Retrieiving and Storing data
  //******************************************************

  /**
   * Returns an array containing the column names.
   */
  public function columnNames():NSArray {
    return m_columns.allKeys();
  }

    /**
   * Returns an array containing the column values.
   */
   public function rowValues():NSArray {
     return m_rows.allValues();
   }

  /**
   * Returns the value for <code>field</code> for the record at <code>index</code>.
   */
  public function valueForFieldAtIndex(field:String, index:Number):Object {
    if(index>m_length || index<0) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      NSException.NSRange, "Invalid index specified",
      NSDictionary.dictionaryWithObjectsAndKeys(index, "index", m_length, "max"));
      trace(e);
      throw e;
    }
    if (m_rows.objectForKey(index.toString())) {
      return m_rows.objectForKey(index.toString())[m_columns.objectForKey(field)];
    } else {
      trace(ASDebugger.info("retreiving from server..."));
      retrieveRecords(index);

      return null;
    }
  }

  /**
   * Sets the value for <code>field</code> for the record at <code>index</code> to
   * <code>value</code>.
   *
   * Note that the function does not ensure that the backend will be able to store
   * <code>value</code>.
   */
  public function setValueForFieldAtIndex(field:String, index:Number, value:Object):Void {
    var val:Object = m_rows.objectForKey(index.toString());
    val[m_columns.objectForKey(field)] = value;
    m_rows.setObjectForKey(val, index.toString());
  }

  /**
   * Replaces the record at <code>index</code> with <code>val</code>.
   *
   * @throws ASInvalidCondition if the length of <code>vals</code> is not equal to
   * that of the number of columns.
   */
  public function replaceRecordAtIndex(val:Array, index:Number):Void {
    if(val.length!=m_columns.count()) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "ASInvalidCondition", "vals must contain the same number of fields as colNames");
      trace(e);
      throw e;
    }
    try {
      m_rows.setObjectForKey(val, index.toString());
    } catch(e:NSException) {
      trace(e);
      throw e;
    }
  }

  /**
   * Returns an array containing the values for <code>field</code> found in all records.
   * It is of the same length as the number of records.
   *
   * Similar to the query "SELECT field FROM table;"
   */
  public function valuesForField(field:String):Array {
    var ret:Array = [];
    var items:Array = m_rows.allKeys().internalList();
    for(var i:String in items) {
      ret.push(valueForFieldAtIndex(field, items[i]));
    }
    return ret;
  }

  //******************************************************
  //*                 Inserting data
  //******************************************************

  /**
   * Inserts <code>val</code> at <code>index</code>.
   */
  public function insertRecordAtIndex(val:Array, index:Number):Void {
    if(val.length!=m_columns.count()) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "ASInvalidCondition", "vals must contain the same number of fields as colNames");
      trace(e);
      throw e;
    }
    try {
      m_rows.setObjectForKey(val, index.toString());
    } catch (e:NSException) {
      trace(e);
      throw e;
    }
  }

  /**
   * Appends <code>val</code> to the record list.
   */
  public function insertRecord(val:Array):Void {
    try {
      insertRecordAtIndex(val, m_rows.count());
    } catch (e:NSException) {
      trace(e);
      throw e;
    }
  }

  /**
   * Inserts a column named <code>col</code> at <code>index</code>.
   */
  public function insertColumnAtIndex(col:String, index:Number):Void {
    try {
      //pad the current records to maintain a consistent state
      var i:Number = m_rows.count();
      var arr:Array;
      while(i--) {
        arr = Array(m_rows.objectForKey(i.toString()));
        arr.splice(index, 0, DEFAULT_PAD);
      }
      m_columns.setObjectForKey(index, col);
    } catch (e:NSException) {
      trace(e);
      throw e;
    }
  }

  /**
   * Appends a column named <code>col</code> to the list of columns.
   */
  public function insertColumn(col:String):Void {
    try {
      insertColumnAtIndex(col, m_columns.count());
    } catch (e:NSException) {
      trace(e);
      throw e;
    }
  }

  //******************************************************
  //*                 Removing data
  //******************************************************

  /**
   * Removes the record at <code>index</code>.
   */
   public function removeRecordAtIndex(index:Number):Void {
     try {
       m_rows.removeObjectForKey(index.toString());
     } catch(e:NSException) {
       trace(e);
       throw e;
     }
   }

   /**
    * Removes the column named <code>col</code> and all associated values.
    */
    public function removeColumn(col:String):Void {
      var id:Number = Number(m_columns.allKeysForObject(col));
      var i:Number = m_rows.count();
      var keys:NSArray = m_rows.allKeys();
      var row:Array;
      while(i--) {
      	row = Array(m_rows.objectForKey(String(keys.objectAtIndex(i))));
      	row.splice(id, 1);
      }
      m_columns.removeObjectForKey(col);
    }

  //******************************************************
  //*                 Service Callbacks
  //******************************************************

  /**
   * This callback inserts data into the record set. Note that it has no way of distinguishing
   * if the <code>res</code> is indeed the response to a request by
   * <code>ASRecordSet</code>.
   */
  private function didReceiveResponse(res:ASResponse):Void {
    var data:Object = res.response();
    //insert items, note that Page can contain more than one item
    var items:Array = Array(data.Page);
    var i:Number = items.length;
    var j:Number = Number(data.Cursor);
    var index:Number;

    while(i--) {
      index = i+j;
      m_rows.setObjectForKey(items[i], index.toString());
    }
    m_responder[DEFAULT_RESULT_METHOD](this, j);

    //perform pending ops
    performPendingOps();
  }

  /**
   * This callback doesn't do anything; it simply routes the fault to the responder.
   */
  private function didEncounterError(res:ASFault):Void {
    m_responder[DEFAULT_FAULT_METHOD](this, res);
  }

  /**
   * Creates an operation array, and passes it to performOp.
   *
   * @see #performOp
   */
  private function retrieveRecords(index:Number):Void {
    performOp([m_itemId, index, m_pageSize]);
  }

  /**
   * Either retrieves the records as specified in the <code>args</code> array,
   * or pushes it onto a stack for access at a later date.
   *
   * Note that it doesn't clear the <code>isPending</code> flag.
   */
  private function performOp(args:Array):Void {
    if(!m_isPending) {
      (m_service.getRecords.apply(m_service, args)).setResponder(this);
      m_isPending = true;
    } else {
      m_pendingOps.push(args);
    }
  }

  /**
   * Clears the <code>isPending</code> flag. In addition, the first operation on the
   * <code>m_pendingOps</code> stack is removed and passed to
   * <code>performOp</code>
   *
   * Note that it doesn't check if the executed operation is successful, since it is not
   * present on the stack.
   */
  private function performPendingOps():Void {
    m_isPending = false;
    //remove the completed operation
    var op:Array = Array(m_pendingOps.shift());
    if(op!=null) {
      performOp(op);
    }
  }

  //******************************************************
  //*                 Responder
  //******************************************************

  /**
   * <p>
   * Sets the responder to <code>responder</code>, which will be invoked when a page
   * request is performed.
   * </p>
   *
   * <p>
   * This object should implement two methods:
   * <ul>
   * <li>
   * <code>${DEFAULT_RESULT_METHOD}(ASResponse):Void</code> - Called when the request is
   * successful.
   * </li>
   * <li>
   * <code>${DEFAULT_FAULT_METHOD}(ASFault):Void</code> - Called when a problem is
   * encountered during the request.
   * </li>
   * </ul>
   * </p>
   */
  public function setResponder(responder:Object):Void {
    m_responder = responder;
  }

  /**
   * Returns this pending call's operation.
   */
  public function responder():Object {
    return m_responder;
  }

  //******************************************************
  //*                 Delivery Modes
  //******************************************************

  /**
   * The mode controlling functions share similar naming conventions:
   * <code>
   * turnOn{ASDeliveryMode.modeName}Mode(dontGo:Boolean, size:Number, pages:Number)
   * </code>
   *
   * All arguments are optional.
   */

  /**
   * Sets the mode to <code>ASDeliveryMode.OnDemand</code>, and the page size to 1.
   *
   * No records are retrieved immediately.
   */
  public function turnOnOnDemandMode():Void {
    m_mode = ASDeliveryMode.OnDemand;
    m_pageSize = 1;
  }

  /**
   * Sets the mode to <code>ASDeliveryMode.FetchAll</code>.
   *
   * By default, records are retrieved immediately, unless, <code>dontGo</code> is true.
   *
   * For more information on how the page size is validated, see
   * <code>validValuesForPagesSize</code>.
   */
  public function turnOnFetchAllMode(dontGo:Boolean, size:Number):Void {
    m_mode = ASDeliveryMode.FetchAll;
    var ret:Array = validValuesForPagesSize(Infinity, size);
    m_pageSize = ret[1];
    m_pages = ret[0];
    if(!dontGo) {
      //fetch all pages
      retrievePages(m_pages, m_pageSize);
    }
  }

  /**
   * Sets the mode to <code>ASDeliveryMode.Page</code>.
   *
   * By default, records are retrieved immediately, unless, <code>dontGo</code> is true.
   *
   * For more information on how the page size is validated, see
   * <code>validValuesForPagesSize</code>.
   */
  public function turnOnPageMode(dontGo:Boolean, size:Number, pages:Number):Void {
    m_mode = ASDeliveryMode.Page;
    var ret:Array = validValuesForPagesSize(pages, size);
    m_pageSize = ret[1];
    m_pages = ret[0];
    if(!dontGo) {
      retrievePages(m_pages, m_pageSize);
    }
  }

  /**
   * This method is the one that actually retrieves the records as specified by
   * <code>pages</code> and <code>size</code>.
   *
   * The method will warn "resetting pages", which is for debugging purposes for probably
   * 99.9% of the time.
   *
   * Currently retrieves are traced instead of being carried out.
   */
  private function retrievePages(pages:Number, size:Number):Void {
    var curr:Number = lastIndex();
    var index:Number;
    var end:Number;

    index = --pages*size+curr;
    end = index+size;
    if(end>m_length) {
      trace(ASDebugger.warning("resetting pages: "+end+", "+m_length));
      end = m_length;
    }

    trace(index+", "+end);

    if(pages<=0) {
      trace("done paging");
      return;
    }

    while(pages--) {
      index = pages*size+curr;
      trace(index+", "+(index+size));
    }
  }

  /**
   * Returns an array containing valid values for the number of pages and the page size:
   * <ul>
   * <li>0: # of pages</li>
   * <li>1: # of records in page ie size</li>
   * </ul>
   *
   * Note that pages*size+lastIndex may still exceed the maximum of <code>length</code>.
   */
  private function validValuesForPagesSize(pages:Number, size:Number):Array {
    if(isNaN(pages) || pages<=0) {
      trace(ASDebugger.warning("resetting pages: "+pages+", "+1));
      pages = 1;
    }

    if(isNaN(size)) {
      size = DEFAULT_MIN_PAGESIZE;
    } else if(size < DEFAULT_MIN_PAGESIZE) {
      size = DEFAULT_MIN_PAGESIZE;
    } else if(size > DEFAULT_MAX_PAGESIZE) {
      size = DEFAULT_MAX_PAGESIZE;
    }

    var count:Number = m_length - lastIndex();

    if(size > count) {
      size = count;
      pages = 1;
      trace(ASDebugger.warning(
      "Page size is greater than the number of items available!"));
      //done; get out of here
      return [pages, size];
    }

    var max:Number = Math.round(count / size);
    if(max<=0) {
      max=1;
    }
    if(pages > max) {
      trace(ASDebugger.warning("resetting pages: "+pages+", "+max));
      pages = max;
    }

    return [pages, size];
  }

  //******************************************************
  //*                 Lengths and Indices
  //******************************************************

  /**
   * Returns the number of records available on the server.
   */
  public function length():Number {
    return m_length;
  }

  /**
   * Returns the number of records currently stored on this instance of
   * <code>ASRecordSet</code>.
   */
  public function localLength():Number {
    return m_rows.count();
  }

  /**
   * Returns the index of the last record stored on this instance of
   * <code>ASRecordSet</code>.
   *
   * This may not be equal to <code>localLength</code>(), as random access of records is
   * possible. Eg. available items:
   * <ul>
   * <li>0: data</li>
   * <li>1: data</li>
   * <li>5: data</li>
   * <li>9: data</li>
   * <li>2: data</li>
   * </ul>
   */
  public function lastIndex():Number {
    return parseInt(m_rows.allKeys().internalList()[0])+1;
  }

  //******************************************************
  //*                 Helper functions
  //******************************************************

  /**
   * Returns <code>true</code> if recognized. Simply checks for the existence of
   * the <code>serverInfo</code> property.
   */
  public static function isRecognizedType(data:Object):Boolean {
    return (data.serverInfo!=null);
  }

  /**
   * Helper function to initialize the <code>m_columns</code> dictionary.
   */
  private function initColumns(colNames:Array):Void {
    if(colNames==null) {
      colNames = [];
    }
    var i:Number = colNames.length;
    var objs:Array = [];
    while(i--) {
      objs[i] = i;
    }

    m_columns = NSDictionary.dictionaryWithObjectsForKeys(
    NSArray.arrayWithArray(objs),
    NSArray.arrayWithArray(colNames));
  }
}