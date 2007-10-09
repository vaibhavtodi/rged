desc "Update pot/po files."
task :updatepo do
     RGED_TEXT_DOMAIN = "rged"
     RGED_VERSION     = "rged 0.9"
     require 'gettext/utils'
     GetText.update_pofiles(RGED_TEXT_DOMAIN, Dir.glob("{app/controllers,app/views,app/views/layouts,app/views/index,app/views/directory,lib}/**/*.{rb,rhtml,rxml}"), RGED_VERSION)
end

desc "Create mo-files"
task :makemo do
     require 'gettext/utils'
     GetText.create_mofiles(true, "po", "locale")
end
