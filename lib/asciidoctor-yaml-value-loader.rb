require 'asciidoctor'
require 'yaml'
require 'uri'

class YamlValueLoaderFilePathTreeProcessor < Asciidoctor::Extensions::TreeProcessor
  def process(document)
    document.set_attr('yaml-value-loader-target-file', document.attr('docfile'))
  end
end


class YamlValueLoaderInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
  include Asciidoctor::Logging

  use_dsl

  named "yaml-value"
  name_positional_attributes 'delimitter'
  default_attrs 'delimiter' => '/'

  def process parent, target, attrs

    path, query = target.split(':', 2)
    delimiter = attrs['delimiter']

    dir = File.dirname(parent.document.attr('yaml-value-loader-target-file'))

    query = query.split(delimiter).map do |q|
      decoded = URI.decode_www_form_component(q)
      if decoded.match(/^\d+$/) then
        decoded.to_i
      else
        decoded
      end
    end

    filepath = File.join(dir, path)
    yaml = YAML.load(File.open(File.join(dir, path), 'r:utf-8', &:read))

    content = yaml.dig(*query)
    parent.logger.warn "yaml-value-loader: #{target} has no value." if content.nil?

    content = case content
    when String
      content
    when Numeric
      content.to_s
    else
      YAML.dump(content)
    end

    create_inline_pass parent, content, attributes: { 'subs' => :normal } 
  end
end

Asciidoctor::Extensions.register do
  tree_processor YamlValueLoaderFilePathTreeProcessor
  inline_macro YamlValueLoaderInlineMacro
end 
