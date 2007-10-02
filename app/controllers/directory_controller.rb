# Directory method
class DirectoryController < ApplicationController
  def list
    return_data = Hash.new()      
    dir = (params[:dir] || 'dir')
    return_data[:FilesCount] = 3      
    return_data[:Files] = [{:name => dir, :size => 1254654, :lastChange => '2007-03-03'},
                            {:name => 'titi.txt', :size => 1023, :lastChange => '2007-10-23'},
                            {:name => 'tutu.txt', :size => 45675688600, :lastChange => '2007-05-01'}
    ]
    render :text=>return_data.to_json, :layout=>false
  end
end
