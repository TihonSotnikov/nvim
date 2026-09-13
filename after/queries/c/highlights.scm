;; extends

((preproc_arg) @keyword.modifier
  (#any-of? @keyword.modifier "extern" "static" "inline" "const" "volatile" "restrict" "register" "constexpr"))

((preproc_arg) @type.builtin
  (#any-of? @type.builtin "void" "bool" "char" "short" "int" "long" "float" "double" "signed" "unsigned"))
