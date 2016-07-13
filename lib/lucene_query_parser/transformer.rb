module LuceneQueryParser
  class Transformer < Parslet::Transform
    rule(:term => simple(:term)) { "#{term}" }
    rule(:term => simple(:term), :similarity => simple(:similarity)) { "#{term}~#{similarity}" }
    rule(:term => simple(:term), :boost => simple(:boost)) { "#{term}^#{boost}" }
    rule(:phrase => simple(:phrase), :boost => simple(:boost)) { "\"#{phrase}\"^#{boost}" }
    rule(:phrase => simple(:phrase)) { "\"#{phrase}\"" }
    rule(:phrase => simple(:phrase), :distance => simple(:distance)) { "\"#{phrase}\"~#{distance}" }
    rule(:group => simple(:exprs)) { "(#{exprs})"}
    rule(:operand => simple(:operand)) { "#{operand}" }
    rule(:unary_operator => subtree(:uo), :operand => subtree(:operand)) { "#{uo}#{operand}" }
    rule(:required => simple(:op)) { "#{op}"}
    rule(:prohibited => simple(:op)) { "#{op}"}
    rule(:field => simple(:field), :operand => simple(:operand)) { "#{field}:#{operand}" }
    rule(:field => simple(:field), :inclusive_range => subtree(:range)) { "#{field}:[#{range}]" }
    rule(:field => simple(:field), :exclusive_range => subtree(:range)) { "#{field}:{#{range}}" }
    rule(:from => simple(:from), :to => simple(:to)) { "#{from} TO #{to}" }
    rule(sequence(:exprs)) { exprs.join " " }
  end
end

# module LuceneQueryParser
#   class Transformer < Parslet::Transform
#     rule(:term => simple(:term)) { "#{term}" }
#     rule(:phrase => simple(:phrase)) { "\"#{phrase}\"" }
#     rule(:phrase => simple(:phrase), :distance => simple(:distance)) { "\"#{phrase}\"~#{distance}" }
#     rule(:group => simple(:exprs)) { "(#{exprs})"}
#     rule(sequence(:exprs)) { exprs.join " " }
#     rule(:group => sequence(:operand), :required => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:group => sequence(:operand), :prohibited => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:field => simple(:operand), :required => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:field => simple(:operand), :prohibited => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:term => simple(:operand), :required => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:term => simple(:operand), :prohibited => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:phrase => simple(:operand), :required => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     rule(:phrase => simple(:operand), :prohibited => simple(:unary_operator)) { "#{unary_operator}#{operand}" }
#     #rule(subtree(:expr)) { expr }
#   end
# end
