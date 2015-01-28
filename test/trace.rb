#set_trace_func proc { |event, file, line, id, binding, classname|
#  printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

STDOUT.sync = true

$indent = 0
set_trace_func proc { |event, file, line, id, binding, classname|
   if event == "line"
       # Ignore
   elsif %w[return c-return end].include?(event)
       $indent -= 2
   else
       obj = eval("self", binding)
       if event == "class"
           STDERR.printf "%*s%s %s\n", $indent, "", event, obj
       else
           obj = "<#{obj.class}##{obj.object_id}>" if id == :initialize
           STDERR.printf "%*s%s %s.%s\n", $indent, "", event, obj, id
       end
       $indent += 2 if %w[call c-call class].include?(event)
   end
}
