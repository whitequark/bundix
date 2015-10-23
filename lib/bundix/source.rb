module Bundix
  module Source
    autoload :Base, 'bundix/source/base'
    autoload :Gem,  'bundix/source/gem'
    autoload :Git,  'bundix/source/git'
    autoload :Path, 'bundix/source/path'
  end
end
