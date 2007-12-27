require 'yaml'

module SchedulerHelper
  
  attr_reader :day 

  
  @@weekDay = "['0'], 
      ['1'], 
      ['2'], 
      ['3'], 
      ['4'], 
      ['5'], 
      ['6'] 
    "  
  
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
     hideLabel:true,
     allowNegative:false,
     minValue:#{min},
     maxValue:#{max},"
     ret = ret + "\n     minText:\""+_("The minimum value for this field is #{min}")+"\",\n     maxText:\""+_("The maximum value for this field is #{max}")+"\",\n     value:#{min}"
  end
  
  def get_combo(id, editable, empty, data)
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
     hideLabel:true,
     triggerAction: 'all',
     store:new Ext.data.SimpleStore(
          {
            fields: ['field'],
            data:[
                  #{@@weekDay}
                  ]
          }),
      selectOnFocus:true\n" 
  end
  
end
