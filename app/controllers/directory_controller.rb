# Directory method
class DirectoryController < ApplicationController

  def list
    return_data = Hash.new()
    dir = (params[:dir] || '/')

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
            begin
              return_data[:Files][i] = {:name => filename, :size => File.size(dir + filename), :lastChange => File.atime(dir + filename).asctime}
            rescue
              return_data[:Files][i] = {:name => 'Error with ' + filename + ' ', :size => 0, :lastChange => ''}
            end
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

  def rename
    newname = (params[:newname] || 'newname')
    oldname = (params[:oldname] || 'oldname')

    return_data = Object.new
    if File.exist?(oldname) then
      begin
        File.rename(oldname, newname)
        return_data = {:success => true}
      rescue
        ########################
      end
    else
      return_data = {:success => false, :error => "Cannot rename file " + oldname + " to " + newname}
    end

    render :text=>return_data.to_json, :layout=>false
  end

  def newdir
    dir = (params[:dir] || 'dir')

        return_data = Object.new
    if File.exist?(dir) == false then
      begin
        Dir.mkdir(dir)
        return_data = {:success => true}
      rescue
        ########################
      end
    else
      return_data = {:success => false, :error => "Cannot create directory: " + dir}
    end

    render :text=>return_data.to_json, :layout=>false

  end

  def delete
    file = (params[:file] || 'file')

    return_data = Object.new
    if File.exist?(file)  then
      begin
        File.delete(file)
        return_data = {:success => true}
      rescue
        ########################
      end
    else
      return_data = {:success => false, :error => "Cannot delete: " + file}
    end

    render :text=>return_data.to_json, :layout=>false

  end




end
