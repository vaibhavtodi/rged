require 'yaml'

module SchedulerHelper
  
  attr_reader :day 

  
  @@weekDay = "['Any'], 
      ['0'], 
      ['1'], 
      ['2'], 
      ['3'], 
      ['4'], 
      ['5'], 
      ['6'] 
    "  
  @@week = "['1'],
            ['2'],
            ['3'],
	    ['4'],
            ['5']"
  
  @@month =   "['January'],
        ['February'],
	['March'],
	['April'],
	['May'],
	['June'],
	['July'],
	['August'],
	['September'],
	['October'],
	['November'],
	['December']"
  
  
  def get_checkbox(id, name, label)
    "
    xtype:'checkbox',
    fieldLabel:'#{label}',
    inputValue:'cbvalue',
    id:'#{id}'\n"
  end
  
  def get_numberfield(id, max, min)
    ret = "
     xtype:'numberfield',
     id: '#{id}',
     autoHeight:true,
     width:120,
     allowNegative:false,
     minValue:#{min},
     maxValue:#{max},"
     ret = ret + "\n     minText:\""+_("The minimum value for this field is #{min}")+"\",\n     maxText:\""+_("The maximum value for this field is #{max}")+"\",\n     value:#{min}"
  end
  
  def get_combo(id, editable, empty, data)
    tmp = ""
    case data
    when "day"
      tmp = @@weekDay
    when "week"
      tmp = @@week
    when "month"
      tmp = @@month
    end

    "
     xtype: 'combo',
     id:'#{id}',
     editable:#{editable},
     emptyText:'#{empty}',
     autoHeight:true,
     width:120,
     displayField:'field',
     typeAhead: true,
     mode: 'local',
     triggerAction: 'all',
     store:new Ext.data.SimpleStore(
          {
            fields: ['field'],
            data:[
                  #{tmp}
                  ]
          }),
      selectOnFocus:true\n" 
  end
  
end
