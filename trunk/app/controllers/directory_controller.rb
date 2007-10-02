# Directory method
class DirectoryController < ApplicationController
  def list
    return_data = Hash.new()
    #dir = (params[:dir] || 'dir')
    dir = "/Users/papywarrior/ProjsPerso/lesotdudestinRubyDev/rged"

    if dir == nil || dir == "" then
      dir = "."
    end

    if File.exist?(dir) then
      i = 0
      return_data[:Files] = Array.new
      if File.directory?(dir) then
        d = Dir.entries(dir)
        d.each{
          |filename|
          if filename != "." && filename != ".." then
            return_data[:Files][i] = {:name => filename, :size => File.size(filename), :lastChange => File.atime(filename).asctime}
            i = i + 1
          end
        }
      end
    end

    if (return_data[:Files] != nil) then
      return_data[:FilesCount] = return_data[:Files].length
    else
      return_data[:FilesCount] = 0
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def get
    #    dir = "/Users/papywarrior/ProjsPerso/lesotdudestinRubyDev/rged/"
    dir = (params[:path] || 'path')
    if dir == nil || dir == "" then
      dir = "."
    end

    if File.exist?(dir) then
      i = 0
      return_data = Array.new
      if File.directory?(dir) then
        d = Dir.entries(dir)
        d.each{
          |filename|
          if File.readable?(filename) && File.executable?(filename) == false && File.writable?(filename) == false then
            readonly = true
          end
          if filename != "." && filename != ".." then
            if File.directory?(filename) then
              if readonly then
                return_data[i] = {:text => filename, :cls => "folder", :disabled => true, :leaf => false}
              else
                return_data[i] = {:text => filename, :cls => "folder", :disabled => false, :leaf => false}
              end

            else
              if readonly then
                return_data[i] = {:text => filename, :cls => File.extname(filename).sub(".", 'file-'), :disabled => false, :leaf => true}
              else
                return_data[i] = {:text => filename, :cls => File.extname(filename).sub(".", 'file-'), :disabled => false, :leaf => true}
              end
            end
            i = i + 1
          end
        }
      end
    end
    render :text=>return_data.to_json, :layout=>false
  end

#  def rename
#    newname = dir = (params[:newname] || 'newname')


#  end

end
