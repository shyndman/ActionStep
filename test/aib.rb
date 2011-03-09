class Color
  attr_accessor :named_value, :hex_value
  def self.hex(value)
    c = Color.new
    c.hex_value = value
    c
  end
  def self.method_missing(method, *args)
    c = Color.new
    c.named_value = method
    c
  end
  def to_xml
    @hex_value ? "\"!#{@hex_value}\"" : "\"!#{@named_value}\""
  end
end

class ASBuilder
  
  class Widget
    def initialize(klass)
      @klass = klass
      @attributes = {}
      @objects = []
    end
    
    def id(value)
      @id = value
      self
    end
    
    def add(klass)
      widget = Widget.new(klass)
      yield widget if block_given?
      @objects << widget
      widget
    end
    
    def method_missing(method, *args)
      @attributes[method] = args[0]
      self
    end
    
    def to_xml
      xml = "<#{@klass} id=\"#{@id}\""
      @attributes.each do |attribute, value|
        xml += " #{attribute}="
        case value
          when String
            xml += "\"'#{value}'\""
          when Symbol
            xml += attribute == :id ? "\"#{value}\"" : "\"##{value}\""
          else
            xml += value.respond_to?(:to_xml) ? value.to_xml : "\"#{value}\""
        end
      end
      if @objects.size > 0
        xml += ">\n"
        @objects.each { |object| xml += object.to_xml }
        xml += "</#{@klass}>\n"
      else
        xml += "/>\n"
      end
      xml
    end
  end

  class Instance
    def initialize(klass)
      @klass = klass
      @bindings = {}
    end
    
    def id(value)
      @id = value
      self
    end
    
    def bind(var, id)
      @bindings[var] = id
      self
    end
    
    def to_xml
      xml = "<instance id=\"#{@id}\" instanceOf=\"#{@klass}\""
      @bindings.each { |var, id| xml += " #{var}=\"##{id}\"" }
      xml += "/>\n"
      xml
    end
  end
  
  class Objects
    def initialize
      @objects = []
      @instances = []
    end
    
    def add(klass)
      widget = Widget.new(klass)
      yield widget if block_given?
      @objects << widget
      widget
    end
    
    def instance(klass)
      instance = Instance.new(klass)
      yield instance if block_given?
      @instances << instance
      instance
    end
    
    def to_xml
      xml = "<objects>\n"
      @objects.each {|widget| xml += widget.to_xml}
      @instances.each {|instance| xml += instance.to_xml}
      xml += "</objects>\n"
    end
  end
  
  def objects
    @objects ||= Objects.new
    yield @objects if block_given?
    @objects
  end
  
  def to_xml
    xml = "<?xml version=\"1.0\"?>\n<!DOCTYPE asmarkup>\n<asmarkup>\n<connectors/>\n"
    xml += objects.to_xml
    xml += "</asmarkup>"
  end
end
