require 'zip/zip'
require 'zip/zipfilesystem'
require 'find'

module Platform

   if RUBY_PLATFORM =~ /darwin/i
      OS = :unix
      IMPL = :macosx
   elsif RUBY_PLATFORM =~ /linux/i
      OS = :unix
      IMPL = :linux
   elsif RUBY_PLATFORM =~ /freebsd/i
      OS = :unix
      IMPL = :freebsd
   elsif RUBY_PLATFORM =~ /netbsd/i
      OS = :unix
      IMPL = :netbsd
   elsif RUBY_PLATFORM =~ /mswin/i
      OS = :win32
      IMPL = :mswin
   elsif RUBY_PLATFORM =~ /cygwin/i
      OS = :unix
      IMPL = :cygwin
   elsif RUBY_PLATFORM =~ /mingw/i
      OS = :win32
      IMPL = :mingw
   elsif RUBY_PLATFORM =~ /bccwin/i
      OS = :win32
      IMPL = :bccwin
   elsif RUBY_PLATFORM =~ /wince/i
      OS = :win32
      IMPL = :wince
   elsif RUBY_PLATFORM =~ /vms/i
      OS = :vms
      IMPL = :vms
   elsif RUBY_PLATFORM =~ /os2/i
      OS = :os2
      IMPL = :os2 # maybe there is some better choice here?
   elsif RUBY_PLATFORM =~ /solaris/i # tnx to Hugh Sasse
      OS = :unix
      IMPL = :solaris
   elsif RUBY_PLATFORM =~ /irix/i # i.e. mips-irix6.5
      OS = :unix
      IMPL = :irix
   elsif RUBY_PLATFORM =~ /java/i # jruby
      OS = :java
      IMPL = :java
   else
      OS = :unknown
      IMPL = :unknown
   end

   # whither AIX, SOLARIS, and the other unixen?

   if RUBY_PLATFORM =~ /(i\d86)/i
      ARCH = :x86
   elsif RUBY_PLATFORM =~ /ia64/i
      ARCH = :ia64
   elsif RUBY_PLATFORM =~ /powerpc/i
      ARCH = :powerpc
   elsif RUBY_PLATFORM =~ /alpha/i
      ARCH = :alpha
   elsif RUBY_PLATFORM =~ /sparc/i
      ARCH = :sparc
   elsif RUBY_PLATFORM =~ /mips/i
      ARCH = :mips # is actually a Silicon Graphics Indigo. How should that be represented ?
   else
      ARCH = :unknown
   end

   # What about AMD, Turion, Motorola, etc..?

end


# Directory method

class DirectoryController < ApplicationController

before_filter :login_required

 def home
   os = Platform::OS
   impl = Platform::IMPL
   user = current_user

   if "#{os}" != "java"
     if "#{os}" =~ /unix/ && "#{impl}" =~ /macosx/ then
       return "/Users/#{user.login}"
     else
       return "/home/#{user.login}"
     end
   else
     require 'java'
     include_class 'java.lang.System'
     home = "#{System.getenv("HOME")}"
     user_tmp = "#{System.getenv("USER")}"
     home = home.sub(user_tmp, '')
     return home + user.login
   end
 end

 def protect_dir(dir)
    if dir =~ /\.\./ then
      raise "Protect dir"
    end
  end

  def get_dir(name, rep = true)
    dir = (params[name] || '')
    dir = '/' + dir unless dir.starts_with?('/')
    if rep == true then
      dir += '/' unless dir.ends_with?('/')
    end
    dir = self.home + dir
    protect_dir(dir)
    return dir
  end

  def list
    dir = get_dir(:path)
    return_data = Hash.new()

    if File.exist?(dir) then
      i = 0
      return_data[:Files] = Array.new
      if File.directory?(dir) then
        d = Dir.entries(dir)
        d.each{
          |filename|
          if filename[0,1] != '.' then
            begin
              return_data[:Files][i] = {
                :name => filename,
                :size => File.size(dir + filename),
                :lastChange => File.atime(dir + filename).asctime,
                :path => dir.sub(self.home, '') + filename,
                :cls => ((File.directory?(dir + filename)) ? 'folder' : File.extname(filename).sub(".", 'file-'))
              }
            rescue
              return_data[:Files][i] = {
                :name => 'Error with ' + filename + ' ',
                :size => 0,
                :lastChange => '',
                :path => '',
                :cls => ''
                }
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
    dir = get_dir(:path)
    i = 0
    return_data = Array.new
    if File.directory?(dir) then
      d = Dir.entries(dir)
      d.each{
        |filename|
        if File.readable?(dir + filename) && File.executable?(dir + filename) == false && File.writable?(dir + filename) == false then
          readonly = true
        end
        if filename[0,1] != '.' then
          if File.directory?(dir + filename) then
            return_data[i] = {
              :id => dir.sub(self.home, '') + filename,
              :text => filename,
              :path => filename,
              :cls => "folder",
              :disabled => readonly,
              :leaf => false
              }
          else
            return_data[i] = {
              :id => dir.sub(self.home, '') + filename,
              :text => filename,
              :path => filename,
              :cls => File.extname(filename).sub(".", 'file-'),
              :disabled => false,
              :leaf => true
              }
          end
          i = i + 1
        end
      }
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def rename
    newname = get_dir(:newname, false)
    oldname = get_dir(:oldname, false)
    return_data = Object.new
    if File.exist?(oldname) then
      begin
        File.rename(oldname, newname)
        return_data = {:success => true}
      rescue
        return_data = {:success => false, :error => _("Cannot rename file ") + oldname.sub(self.home, '') + _(" to ") + newname.sub(self.home, '')}
      end
    else
      return_data = {:success => false, :error => _("Cannot rename file ") + oldname.sub(self.home, '') + _(" to ") + newname.sub(self.home, '')}
    end

    render :text=>return_data.to_json, :layout=>false
  end

  def newdir

    dir = get_dir(:dir)
    return_data = Object.new
    if File.exist?(dir) == false then
      begin
        Dir.mkdir(dir)
        return_data = {:success => true}
      rescue
        ########################
      end
    else
      return_data = {:success => false, :error => _("Cannot create directory: ") + dir.sub(self.home, '')}
    end

    render :text=>return_data.to_json, :layout=>false

  end

  def delete
    file = get_dir(:file, false)
    return_data = Object.new
    if File.exist?(file)  then
      begin
        if File.directory?(file) then
          Dir.delete(file)
        else
          File.delete(file)
        end
        return_data = {:success => true}
      rescue
        return_data = {:success => false, :error => _("Cannot delete: ") + file.sub(self.home, '')}
      end
    else
      return_data = {:success => false, :error => _("Cannot delete: ") + file.sub(self.home, '')}
    end

    render :text=>return_data.to_json, :layout=>false

  end

  def download
    file = get_dir(:file, false)
    if File.exist?(file)  then
      begin
        if File.directory?(file) then
          folder = true
          archive = File.basename(file)
          Zip::ZipFile.open(archive + ".zip", Zip::ZipFile::CREATE){
            |zipfile|
            Find.find(file) do
              |f|
              name = File.basename(f)
              if name[0,1] != '.' && f != file then
                zipfile.add(archive + "/" + name, f)
              end
            end
            }
          file = archive + ".zip"
        end
        send_file(file)
     if folder then
          File.delete(file)
        end
      end
    end
  end

  def upload
    dir = get_dir(:path)
    return_data = Hash.new
    return_data[:success] = true;
    params.each {
      |key, value|
      if key =~ /ext-gen([0-9]*)/ && value != "" then
        file = dir + (value.original_filename || key)
        if File.exist?(file) then
          return_data[:success] = false;
          return_data[:errors] = Hash.new unless return_data[:errors]
          return_data[:errors][key] = _("File ") + file.sub(self.home, '') + _(" allready exist")
        else
          begin
            File.open(file, "w") { |f| f.write(value.read) }
          rescue
            return_data[:success] = false;
            return_data[:errors] = Hash.new unless return_data[:errors]
            return_data[:errors][key] = _("File ") + file.sub(self.home, '') + _(" can't be uploaded")
          end
        end
      end
    }
    response.headers['Content-type'] = 'text/html, charset=utf-8'
    render :text=>return_data.to_json, :layout=>false
  end

end
