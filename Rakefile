namespace :mongodb do
  desc "Start MongoDB for development"
  task :start do
    mkdir_p "db"
    system "mongod --dbpath db/"
  end
end

namespace :hive do
  desc "Start The Hive for development"
  task :start do
    system "shotgun config.ru"
  end
end

desc "Start everything."
multitask :start => [ 'mongodb:start', 'hive:start' ]

