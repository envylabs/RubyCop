module RubyCop
  class NodeBuilder < Ripper::SexpBuilder
    def initialize(src, filename=nil, lineno=nil)
      @src = src ||= filename && File.read(filename) || ''
      @filename = filename
      super
    end

    class << self
      def build(src, filename=nil)
        new(src, filename).parse
      end
    end

    def on_alias(new_name, old_name)
      Ruby::Alias.new(to_ident(new_name), to_ident(old_name))
    end

    def on_aref(target, args)
      Ruby::Call.new(target, ident(:[]), args)
    end

    def on_aref_field(target, args)
      Ruby::Call.new(target, ident(:[]), args)
    end

    def on_arg_paren(args)
      args
    end

    def on_args_add(args, arg)
      args.add(arg); args
    end

    def on_args_add_block(args, block)
      args.add_block(block) if block; args
    end

    def on_args_new
      Ruby::Args.new
    end

    def on_array(args)
      args ? args.to_array : Ruby::Array.new
    end

    def on_assign(lvalue, rvalue)
      lvalue.assignment(rvalue, ident(:'='))
    end

    def on_assoc_new(key, value)
      Ruby::Assoc.new(key, value)
    end

    def on_assoclist_from_args(args)
      args
    end

    def on_bare_assoc_hash(assocs)
      Ruby::Hash.new(assocs)
    end

    def on_BEGIN(statements)
      Ruby::Call.new(nil, ident(:BEGIN), nil, statements)
    end

    def on_begin(body)
      body.is_a?(Ruby::ChainedBlock) ? body : body.to_chained_block
    end

    def on_binary(lvalue, operator, rvalue)
      Ruby::Binary.new(lvalue, rvalue, operator)
    end

    def on_blockarg(arg)
      arg
    end

    def on_block_var(params, something)
      params
    end

    def on_bodystmt(body, rescue_block, else_block, ensure_block)
      statements = [rescue_block, else_block, ensure_block].compact
      statements.empty? ? body : body.to_chained_block(statements)
    end

    def on_brace_block(params, statements)
      statements.to_block(params)
    end

    def on_break(args)
      Ruby::Call.new(nil, ident(:break), args)
    end

    def on_call(target, separator, identifier)
      Ruby::Call.new(target, identifier)
    end

    def on_case(args, when_block)
      Ruby::Case.new(args, when_block)
    end

    def on_CHAR(token)
      Ruby::Char.new(token, position)
    end

    def on_class(const, superclass, body)
      Ruby::Class.new(const, superclass, body)
    end

    def on_class_name_error(ident)
      raise SyntaxError, 'class/module name must be CONSTANT'
    end

    def on_command(identifier, args)
      Ruby::Call.new(nil, identifier, args)
    end

    def on_command_call(target, separator, identifier, args)
      Ruby::Call.new(target, identifier, args)
    end

    def on_const(token)
      Ruby::Constant.new(token, position)
    end

    def on_const_path_field(namespace, const)
      const.namespace = namespace; const
    end

    def on_const_path_ref(namespace, const)
      const.namespace = namespace; const
    end

    def on_const_ref(const)
      const
    end

    def on_cvar(token)
      Ruby::ClassVariable.new(token, position)
    end

    def on_def(identifier, params, body)
      Ruby::Method.new(nil, identifier, params, body)
    end

    def on_defs(target, separator, identifier, params, body)
      Ruby::Method.new(target, identifier, params, body)
    end

    def on_defined(ref)
      Ruby::Defined.new(ref)
    end

    def on_do_block(params, statements)
      statements.to_block(params)
    end

    def on_dot2(min, max)
      Ruby::Range.new(min, max, false)
    end

    def on_dot3(min, max)
      Ruby::Range.new(min, max, true)
    end

    def on_dyna_symbol(symbol)
      symbol.to_dyna_symbol
    end

    def on_else(statements)
      Ruby::Else.new(statements)
    end

    def on_END(statements)
      Ruby::Call.new(nil, ident(:END), nil, statements)
    end

    def on_ensure(statements)
      statements
    end

    def on_if(expression, statements, else_block)
      Ruby::If.new(expression, statements, else_block)
    end
    alias_method :on_elsif, :on_if

    def on_ifop(condition, then_part, else_part)
      Ruby::IfOp.new(condition, then_part, else_part)
    end

    def on_if_mod(expression, statement)
      Ruby::IfMod.new(expression, statement)
    end

    def on_fcall(identifier)
      Ruby::Call.new(nil, identifier)
    end

    def on_field(target, separator, identifier)
      Ruby::Call.new(target, identifier)
    end

    def on_float(token)
      Ruby::Float.new(token, position)
    end

    def on_for(variable, range, statements)
      Ruby::For.new(variable, range, statements)
    end

    def on_gvar(token)
      Ruby::GlobalVariable.new(token, position)
    end

    def on_hash(assocs)
      Ruby::Hash.new(assocs)
    end

    def on_ident(token)
      ident(token)
    end

    def on_int(token)
      Ruby::Integer.new(token, position)
    end

    def on_ivar(token)
      Ruby::InstanceVariable.new(token, position)
    end

    def on_kw(token)
      Ruby::Keyword.new(token, position)
    end

    def on_label(token)
      Ruby::Label.new(token, position)
    end

    def on_lambda(params, statements)
      Ruby::Block.new(statements, params)
    end

    def on_massign(lvalue, rvalue)
      lvalue.assignment(rvalue, ident(:'='))
    end

    def on_method_add_arg(call, args)
      call.arguments = args; call
    end

    def on_method_add_block(call, block)
      call.block = block; call
    end

    def on_mlhs_add(assignment, ref)
      assignment.add(ref); assignment
    end

    def on_mlhs_add_star(assignment, ref)
      assignment.add(Ruby::SplatArg.new(ref)); assignment
    end

    def on_mlhs_new
      Ruby::MultiAssignmentList.new
    end

    def on_module(const, body)
      Ruby::Module.new(const, body)
    end

    def on_mrhs_add(assignment, ref)
      assignment.add(ref); assignment
    end

    def on_mrhs_new_from_args(args)
      Ruby::MultiAssignmentList.new(args.elements)
    end

    def on_next(args)
      Ruby::Call.new(nil, ident(:next), args)
    end

    def on_op(operator)
      operator.intern
    end

    def on_opassign(lvalue, operator, rvalue)
      lvalue.assignment(rvalue, operator)
    end

    def on_params(params, optionals, rest, something, block)
      Ruby::Params.new(params, optionals, rest, block)
    end

    def on_paren(node)
      node
    end

    def on_parse_error(message)
      raise SyntaxError, message
    end

    def on_program(statements)
      statements.to_program(@src, @filename)
    end

    def on_qwords_add(array, word)
      array.add(Ruby::String.new(word)); array
    end

    def on_qwords_new
      Ruby::Array.new
    end

    def on_redo
      Ruby::Call.new(nil, ident(:redo))
    end

    def on_regexp_add(regexp, content)
      regexp.add(content); regexp
    end

    def on_regexp_literal(regexp, rdelim)
      regexp
    end

    def on_regexp_new
      Ruby::Regexp.new
    end

    def on_rescue(types, var, statements, block)
      statements.to_chained_block(block, Ruby::RescueParams.new(types, var))
    end

    def on_rescue_mod(expression, statements)
      Ruby::RescueMod.new(expression, statements)
    end

    def on_rest_param(param)
      param
    end

    def on_retry
      Ruby::Call.new(nil, ident(:retry))
    end

    def on_return(args)
      Ruby::Call.new(nil, ident(:return), args)
    end

    def on_sclass(superclass, body)
      Ruby::SingletonClass.new(superclass, body)
    end

    def on_stmts_add(target, statement)
      target.add(statement) if statement; target
    end

    def on_stmts_new
      Ruby::Statements.new
    end

    def on_string_add(string, content)
      string.add(content); string
    end

    def on_string_concat(*strings)
      Ruby::StringConcat.new(strings)
    end

    def on_string_content
      Ruby::String.new
    end

    # weird string syntax that I didn't know existed until writing this lib.
    # ex. "safe level is #$SAFE" => "safe level is 0"
    def on_string_dvar(variable)
      variable
    end

    def on_string_embexpr(expression)
      expression
    end

    def on_string_literal(string)
      string
    end

    def on_super(args)
      Ruby::Call.new(nil, ident(:super), args)
    end

    def on_symbol(token)
      Ruby::Symbol.new(token, position)
    end

    def on_symbol_literal(symbol)
      symbol
    end

    def on_top_const_field(field)
      field
    end

    def on_top_const_ref(const)
      const
    end

    def on_tstring_content(token)
      token
    end

    def on_unary(operator, operand)
      Ruby::Unary.new(operator, operand)
    end

    def on_undef(args)
      Ruby::Call.new(nil, ident(:undef), Ruby::Args.new(args.collect { |e| to_ident(e) }))
    end

    def on_unless(expression, statements, else_block)
      Ruby::Unless.new(expression, statements, else_block)
    end

    def on_unless_mod(expression, statement)
      Ruby::UnlessMod.new(expression, statement)
    end

    def on_until(expression, statements)
      Ruby::Until.new(expression, statements)
    end

    def on_until_mod(expression, statement)
      Ruby::UntilMod.new(expression, statement)
    end

    def on_var_alias(new_name, old_name)
      Ruby::Alias.new(to_ident(new_name), to_ident(old_name))
    end

    def on_var_field(field)
      field
    end

    def on_var_ref(ref)
      ref
    end

    def on_void_stmt
      nil
    end

    def on_when(expression, statements, next_block)
      Ruby::When.new(expression, statements, next_block)
    end

    def on_while(expression, statements)
      Ruby::While.new(expression, statements)
    end

    def on_while_mod(expression, statement)
      Ruby::WhileMod.new(expression, statement)
    end

    def on_word_add(string, word)
      string.add(word); string
    end

    def on_words_add(array, word)
      array.add(word); array
    end

    def on_word_new
      Ruby::String.new
    end

    def on_words_new
      Ruby::Array.new
    end

    def on_xstring_add(string, content)
      on_string_add(string, content)
    end

    def on_xstring_new
      Ruby::ExecutableString.new
    end

    def on_xstring_literal(string)
      string
    end

    def on_yield(args)
      Ruby::Call.new(nil, ident(:yield), args)
    end

    def on_yield0
      Ruby::Call.new(nil, ident(:yield))
    end

    def on_zsuper(*)
      Ruby::Call.new(nil, ident(:super))
    end

  private

    def ident(ident)
      Ruby::Identifier.new(ident, position)
    end

    def to_ident(ident_or_sym)
      ident_or_sym.is_a?(Ruby::Identifier) ? ident_or_sym : ident(ident_or_sym)
    end

    def position
      Ruby::Position.new(lineno, column)
    end
  end
end