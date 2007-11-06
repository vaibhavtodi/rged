
desc "Update pot/po files."
task :updatepo do
     require 'gettext/utils'
     GetText.update_pofiles("rged", Dir.glob("{app/controllers,app/views,app/views/account,app/views/department,app/views/layouts,app/views/index,app/views/directory,app/views/country,lib}/**/*.{rb,rhtml,rxml}"), "rged")
end

desc "Create mo-files"
task :makemo do
     require 'gettext/utils'
     GetText.create_mofiles(true, "po", "locale")
end
