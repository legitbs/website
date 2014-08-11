require 'fileutils'

task default: ['index.html', 'index.css', '2014']

file 'index.html' => 'index.html.haml' do |t|
  sh "haml #{t.prerequisites.join} #{t.name}"
end

file 'index.css' => 'index.css.sass' do |t|
  sh "sass -r bourbon #{t.prerequisites.join} #{t.name}"
end

task '2014' => ['2014/index.html', '2014/index.css']

file '2014/index.html' => '2014/index.html.haml' do |t|
  sh "haml #{t.prerequisites.join} #{t.name}"
end

file '2014/index.css' => '2014/index.css.sass' do |t|
  sh "sass -r bourbon #{t.prerequisites.join} #{t.name}"
end
