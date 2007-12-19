module SchedulerHelper
  
  attr_reader :day 

  
  @@day = "['Any'], 
      ['Monday'], 
      ['Thuesday'], 
      ['Wednesday'], 
      ['Thursday'], 
      ['Friday'], 
      ['Saturday'], 
      ['Sunday'] 
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
    "xtype:'checkbox',
    boxLabel:'#{label}',
    name:'#{name}',
    inputValue:'cbvalue',
    id:'#{id}'"
  end
  
  def get_combox(id, editable, empty, data)
    tmp = ""
    case data
    when "day"
      tmp = @@day
    when "week"
      tmp = @@week
    when "month"
      tmp = @@month
    end

    "     xtype: 'combo',
          id:'#{id}',
          editable:#{editable},
          emptyText:'#{empty}',
          displayField:'field',
          typeAhead: true,
          mode: 'local',
          triggerAction: 'all',
	  store:new Ext.data.SimpleStore({
            fields: ['field'],
            data:[
                  #{tmp}
                  ]
          }),
	  selectOnFocus:true,
	  x:120,
	  y:-15   
      " 
  end
  
end
