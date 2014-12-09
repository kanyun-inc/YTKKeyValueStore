Pod::Spec.new do |s|
  s.name         = "YTKKeyValueStore"
  s.version      = "0.1.2"
  s.summary      = "A simple Key-Value storage tool, using Sqlite as backend."
  s.homepage     = "https://github.com/yuantiku/YTKKeyValueStore"
  s.license      = "MIT"
  s.author       = { "tangqiao" => "tangqiao@fenbi.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/yuantiku/YTKKeyValueStore.git", :tag => "0.1.2" }
  s.source_files = "YTKKeyValueStore/YTKKeyValueStore.{h,m}"
  s.requires_arc = true
  s.dependency   "FMDB", "~> 2.0"
end
