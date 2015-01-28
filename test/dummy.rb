require 'trace'

sleep 0.5

def a
  b
end

def b
  c
end

def c
end

a
