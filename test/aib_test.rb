require 'test/aib.rb'

builder = ASBuilder.new
builder.objects do |objects|
  objects.add(:window) do |win|
    win.center(true).width(253).height(300).backgroundColor(Color.purple)
    win.title("This is a test").minWidth(253).initialFirstResponder(:button1)
    win.add(:hbox) do |box|
      box.border(5).autoresizingMask(2)
      btn = box.add(:button).id(:button1).width(50).height(22).minXMargin(6).enableXResizing(false)
      btn.title("1").target(:button2).action("performClick").nextKeyView(:button2)
      box.add(:separator).minXMargin(6)
      btn = box.add(:button).id(:button2).width(50).height(22).minXMargin(6).enableXResizing(false)
      btn.title("2").target(:button3).action("performClick").nextKeyView(:button3)
      box.add(:separator).minXMargin(6)
      btn = box.add(:button).id(:button3).width(50).height(22).minXMargin(6).enableXResizing(true).autoresizingMask(2)
      btn.title("3").target(:button4).action("performClick").nextKeyView(:button4)
      box.add(:separator).minXMargin(6)
      box.add(:button).id(:button4).width(50).height(22).title("4").minXMargin(6).enableXResizing(false).nextKeyView(:button1)
    end
  end
  objects.add(:window) do |win|
    win.center(true).x(10).y(60).width(200).height(150)
    win.backgroundColor(Color.hex("0xCC0000")).title("This is another window")
    win.add(:vbox) do |box|
      box.border(5).autoresizingMask(2)
      box.add(:textfield).id(:sourceText).editable(true).selectable(true).width(189).height(22).autoresizingMask(2)
      box.add(:separator).minYMargin(5)
      box.add(:button).width(70).height(22).title("submit").minYMargin(5).target(:controller).action("copyText")
      box.add(:separator).minYMargin(5)
      tf = box.add(:textfield).id(:destText).drawsBackground(false).editable(false).selectable(true)
      tf.width(189).height(22).stringValue("Click Submit, if you dare").autoresizingMask(2)
    end
  end
  objects.instance("sample.Controller").id(:controller).bind(:src, :sourceText).bind(:dest, :destText)
end

File.open("test/aib2.xml", "wb") do |file|
  file.puts builder.to_xml
end
