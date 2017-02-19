class Bundix
  class Nixer
    attr_reader :level, :obj

    HASH_T = ERB.new(<<eot.chomp)
{
<% obj.sort_by{|k,v| k.to_s.downcase}.each do |(k,v)| %><%= indent %><%= serialize_key(k) %> = <%= sub(v,2)%>;
<%end%><%= outdent%>}
eot

    def initialize(obj, level = 0)
      @obj = obj
      @level = level
    end

    def indent
      ' ' * (level + 2)
    end

    def outdent
      ' ' * level
    end

    def sub(obj, indent = 0)
      self.class.new(obj, level + indent).serialize
    end

    def serialize_key(k)
      if k.to_s =~ /^[a-zA-Z_-]+[a-zA-Z0-9_-]*$/
        k.to_s
      else
        sub(k, 2)
      end
    end

    def serialize
      case obj
      when Hash
        return HASH_T.result(binding)
      when Array
        "[#{obj.map{|o| sub(o) }.sort.join(' ')}]"
      when String
        obj.dump
      when Symbol
        obj.to_s.dump
      when true, false
        obj.to_s
      else
        fail "Cannot convert to nix #{obj.inspect}"
      end
    end
  end
end
