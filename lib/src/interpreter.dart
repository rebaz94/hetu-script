import 'environment.dart';
import 'buildin.dart';
import 'errors.dart';
import 'expression.dart';
import 'statement.dart';
import 'value.dart';
import 'namespace.dart';
import 'class.dart';
import 'function.dart';
import 'lexer.dart';
import 'parser.dart';
import 'resolver.dart';

/// 负责对语句列表进行最终解释执行
class Interpreter implements ExprVisitor, StmtVisitor {
  var _evaledFiles = <String>[];

  /// 全局命名空间
  HT_Namespace globals;
  HT_Namespace externs;

  /// 本地变量表，不同语句块和环境的变量可能会有重名。
  /// 这里用表达式而不是用变量名做key，用表达式的值所属环境相对位置作为value
  final _varDistances = <Expr, int>{};

  /// 常量表
  final _constants = <dynamic>[];

  /// 当前语句所在的命名空间
  HT_Namespace curContext;
  String _curFileName;
  String get curFileName => _curFileName;

  Interpreter() {
    globals = HT_Namespace(name: env.lexicon.globals);
    externs = HT_Namespace(name: env.lexicon.externs);

    curContext = globals;
  }

  dynamic eval(String content, String fileName,
      {HT_Namespace context, ParseStyle style = ParseStyle.library, String invokeFunc = null, List<dynamic> args}) {
    curContext = context ?? globals;
    var tokens = Lexer().lex(content);
    var statements = Parser(this).parse(tokens, fileName, style: style);
    Resolver(this).resolve(statements, fileName);
    dynamic result;
    for (var stmt in statements) {
      evaluateStmt(stmt);
    }
    if ((style == ParseStyle.library) && (invokeFunc != null)) {
      result = invoke(invokeFunc, args: args);
    } else if (style == ParseStyle.program) {
      result = invoke(env.lexicon.defaultProgramMainFunc, args: args);
    }
    return result;
  }

  /// 解析文件
  Future<dynamic> evalf(String filepath,
      {String libName, ParseStyle style = ParseStyle.library, String invokeFunc = null, List<dynamic> args}) async {
    _curFileName = filepath;
    dynamic result;
    if (!_evaledFiles.contains(curFileName)) {
      if (env.debugMode) print('hetu: Loading $filepath...');
      _evaledFiles.add(curFileName);

      HT_Namespace library_namespace;
      if ((libName != null) && (libName != env.lexicon.globals)) {
        globals.define(libName, HT_Type.NAMESPACE, null, null, this);
        library_namespace = HT_Namespace(name: libName, closure: library_namespace);
      }

      var content = await env.stringLoadMethod(_curFileName);
      result = await eval(content, curFileName,
          context: library_namespace, style: style, invokeFunc: invokeFunc, args: args);
    }
    _curFileName = null;
    return result;
  }

  /// 解析命令行
  // dynamic evalc(String input) {
  //   HT_Error.clear();
  //   try {
  //     final _lexer = Lexer();
  //     final _parser = Parser(this);
  //     var tokens = _lexer.lex(input, commandLine: true);
  //     var statements = _parser.parse(tokens, null, style: ParseStyle.commandLine);
  //     executeBlock(statements, curContext);
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     HT_Error.output();
  //   }
  // }

  // void addLocal(Expr expr, int distance) {
  //   _locals[expr] = distance;
  // }

  void addVarPos(Expr expr, int distance) {
    _varDistances[expr] = distance;
  }

  /// 定义一个常量，然后返回数组下标
  /// 相同值的常量不会重复定义
  int addLiteral(dynamic literal) {
    var index = _constants.indexOf(literal);
    if (index == -1) {
      index = _constants.length;
      _constants.add(literal);
      return index;
    } else {
      return index;
    }
  }

  /// 链接外部函数，链接时必须在河图中存在一个函数声明
  ///
  /// 此种形式的外部函数通常用于需要进行参数类型判断的情况
  void loadExtern(String name, HT_External function) {
    if (externs.contains(name)) {
      throw HSErr_Defined(name, null, null, curFileName);
    } else {
      externs.define(name, HT_Type(), null, null, this, value: function);
    }
  }

  void loadExterns(Map<String, HT_External> linkMap) {
    for (var key in linkMap.keys) {
      loadExtern(key, linkMap[key]);
    }
  }

  dynamic _getVar(String name, Expr expr) {
    var distance = _varDistances[expr];
    if (distance != null) {
      return curContext.fetchAt(name, distance, expr.line, expr.column, this);
    }

    return globals.fetch(name, expr.line, expr.column, this);
  }

  dynamic unwrap(dynamic value, int line, int column, String fileName) {
    if (value is HT_Value) {
      return value;
    } else if (value is num) {
      return HSVal_Number(value, line, column, this);
    } else if (value is bool) {
      return HSVal_Boolean(value, line, column, this);
    } else if (value is String) {
      return HSVal_String(value, line, column, this);
    } else {
      return value;
    }
  }

  // void interpreter(List<Stmt> statements, {bool commandLine = false, String invokeFunc = null, List<dynamic> args}) {
  //   for (var stmt in statements) {
  //     evaluateStmt(stmt);
  //   }

  //   if ((!commandLine) && (invokeFunc != null)) {
  //     invoke(invokeFunc, args: args);
  //   }
  // }

  dynamic invoke(String name, {String classname, List<dynamic> args}) {
    HT_Error.clear();
    try {
      if (classname == null) {
        var func = globals.fetch(name, null, null, this, recursive: false);
        if (func is HT_Function) {
          return func.call(this, null, null, args ?? []);
        } else {
          throw HSErr_Undefined(name, null, null, curFileName);
        }
      } else {
        var klass = globals.fetch(classname, null, null, this, recursive: false);
        if (klass is HT_Class) {
          // 只能调用公共函数
          var func = klass.fetch(name, null, null, this, recursive: false);
          if (func is HT_Function) {
            return func.call(this, null, null, args ?? []);
          } else {
            throw HSErr_Callable(name, null, null, curFileName);
          }
        } else {
          throw HSErr_Undefined(classname, null, null, curFileName);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      HT_Error.output();
    }
  }

  void executeBlock(List<Stmt> statements, HT_Namespace environment) {
    var saved_context = curContext;

    try {
      curContext = environment;
      for (var stmt in statements) {
        evaluateStmt(stmt);
      }
    } finally {
      curContext = saved_context;
    }
  }

  dynamic evaluateStmt(Stmt stmt) => stmt.accept(this);

  dynamic evaluateExpr(Expr expr) => expr.accept(this);

  @override
  dynamic visitNullExpr(NullExpr expr) => null;

  @override
  dynamic visitLiteralExpr(LiteralExpr expr) => _constants[expr.constantIndex];

  @override
  dynamic visitGroupExpr(GroupExpr expr) => evaluateExpr(expr.inner);

  @override
  dynamic visitVectorExpr(VectorExpr expr) {
    var list = [];
    for (var item in expr.vector) {
      list.add(evaluateExpr(item));
    }
    return list;
  }

  @override
  dynamic visitBlockExpr(BlockExpr expr) {
    var map = {};
    for (var key_expr in expr.map.keys) {
      var key = evaluateExpr(key_expr);
      var value = evaluateExpr(expr.map[key_expr]);
      map[key] = value;
    }
    return map;
  }

  // @override
  // dynamic visitTypeExpr(TypeExpr expr) {}

  @override
  dynamic visitVarExpr(VarExpr expr) => _getVar(expr.name.lexeme, expr);

  @override
  dynamic visitUnaryExpr(UnaryExpr expr) {
    var value = evaluateExpr(expr.value);

    if (expr.op.lexeme == env.lexicon.subtract) {
      if (value is num) {
        return -value;
      } else {
        throw HSErr_UndefinedOperator(value.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
      }
    } else if (expr.op.lexeme == env.lexicon.not) {
      if (value is bool) {
        return !value;
      } else {
        throw HSErr_UndefinedOperator(value.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
      }
    } else {
      throw HSErr_UndefinedOperator(value.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
    }
  }

  @override
  dynamic visitBinaryExpr(BinaryExpr expr) {
    var left = evaluateExpr(expr.left);
    var right;
    if (expr.op == env.lexicon.and) {
      if (left is bool) {
        // 如果逻辑和操作的左操作数是假，则直接返回，不再判断后面的值
        if (!left) {
          return false;
        } else {
          right = evaluateExpr(expr.right);
          if (right is bool) {
            return left && right;
          } else {
            throw HSErr_UndefinedBinaryOperator(
                left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
          }
        }
      } else {
        throw HSErr_UndefinedBinaryOperator(
            left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
      }
    } else {
      right = evaluateExpr(expr.right);

      // TODO 操作符重载
      if (expr.op.type == env.lexicon.or) {
        if (left is bool) {
          if (right is bool) {
            return left || right;
          } else {
            throw HSErr_UndefinedBinaryOperator(
                left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
          }
        } else {
          throw HSErr_UndefinedBinaryOperator(
              left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
        }
      } else if (expr.op.type == env.lexicon.equal)
        return left == right;
      else if (expr.op.type == env.lexicon.notEqual)
        return left != right;
      else if (expr.op.type == env.lexicon.add || expr.op.type == env.lexicon.subtract) {
        if ((left is String) && (right is String)) {
          return left + right;
        } else if ((left is num) && (right is num)) {
          if (expr.op.lexeme == env.lexicon.add) {
            return left + right;
          } else if (expr.op.lexeme == env.lexicon.subtract) {
            return left - right;
          }
        } else {
          throw HSErr_UndefinedBinaryOperator(
              left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
        }
      } else if (expr.op.type == env.lexicon.IS) {
        if (right is HT_Class) {
          return HT_TypeOf(left) == right.name;
        } else {
          throw HSErr_NotType(right.toString(), expr.op.line, expr.op.column, curFileName);
        }
      } else if ((expr.op.type == env.lexicon.multiply) ||
          (expr.op.type == env.lexicon.devide) ||
          (expr.op.type == env.lexicon.modulo) ||
          (expr.op.type == env.lexicon.greater) ||
          (expr.op.type == env.lexicon.greaterOrEqual) ||
          (expr.op.type == env.lexicon.lesser) ||
          (expr.op.type == env.lexicon.lesserOrEqual)) {
        if ((expr.op == env.lexicon.IS) && (right is HT_Class)) {
        } else if (left is num) {
          if (right is num) {
            if (expr.op == env.lexicon.multiply) {
              return left * right;
            } else if (expr.op == env.lexicon.devide) {
              return left / right;
            } else if (expr.op == env.lexicon.modulo) {
              return left % right;
            } else if (expr.op == env.lexicon.greater) {
              return left > right;
            } else if (expr.op == env.lexicon.greaterOrEqual) {
              return left >= right;
            } else if (expr.op == env.lexicon.lesser) {
              return left < right;
            } else if (expr.op == env.lexicon.lesserOrEqual) {
              return left <= right;
            }
          } else {
            throw HSErr_UndefinedBinaryOperator(
                left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
          }
        } else {
          throw HSErr_UndefinedBinaryOperator(
              left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
        }
      } else {
        throw HSErr_UndefinedBinaryOperator(
            left.toString(), right.toString(), expr.op.lexeme, expr.op.line, expr.op.column, curFileName);
      }
    }
  }

  @override
  dynamic visitCallExpr(CallExpr expr) {
    var callee = evaluateExpr(expr.callee);
    var args = <dynamic>[];
    for (var arg in expr.args) {
      var value = evaluateExpr(arg);
      args.add(value);
    }

    if (callee is HT_Function) {
      if (callee.funcStmt.funcType != FuncStmtType.constructor) {
        return callee.call(this, expr.line, expr.column, args ?? []);
      } else {
        //TODO命名构造函数
      }
    } else if (callee is HT_Class) {
      // for (var i = 0; i < callee.varStmts.length; ++i) {
      //   var param_type_token = callee.varStmts[i].typename;
      //   var arg = args[i];
      //   if (arg.type != param_type_token.lexeme) {
      //     throw HetuError(
      //         '(Interpreter) The argument type "${arg.type}" can\'t be assigned to the parameter type "${param_type_token.lexeme}".'
      //         ' [${param_type_token.line}, ${param_type_token.column}].');
      //   }
      // }

      return callee.createInstance(this, expr.line, expr.column, curContext, args: args);
    } else {
      throw HSErr_Callable(callee.toString(), expr.callee.line, expr.callee.column, curFileName);
    }
  }

  @override
  dynamic visitAssignExpr(AssignExpr expr) {
    var value = evaluateExpr(expr.value);
    var distance = _varDistances[expr];
    if (distance != null) {
      // 尝试设置当前环境中的本地变量
      curContext.assignAt(expr.variable.lexeme, value, distance, expr.line, expr.column, this);
    } else {
      globals.assign(expr.variable.lexeme, value, expr.line, expr.column, this);
    }

    // 返回右值
    return value;
  }

  @override
  dynamic visitThisExpr(ThisExpr expr) => _getVar(env.lexicon.THIS, expr);

  @override
  dynamic visitSubGetExpr(SubGetExpr expr) {
    var collection = evaluateExpr(expr.collection);
    var key = evaluateExpr(expr.key);
    if (collection is HSVal_List) {
      return collection.value.elementAt(key);
    } else if (collection is List) {
      return collection[key];
    } else if (collection is HSVal_Map) {
      return collection.value[key];
    } else if (collection is Map) {
      return collection[key];
    }

    throw HSErr_SubGet(collection.toString(), expr.line, expr.column, expr.fileName);
  }

  @override
  dynamic visitSubSetExpr(SubSetExpr expr) {
    var collection = evaluateExpr(expr.collection);
    var key = evaluateExpr(expr.key);
    var value = evaluateExpr(expr.value);
    if ((collection is List) || (collection is Map)) {
      return collection[key] = value;
    } else if ((collection is HSVal_List) || (collection is HSVal_Map)) {
      collection.value[key] = value;
    }

    throw HSErr_SubGet(collection.toString(), expr.line, expr.column, expr.fileName);
  }

  @override
  dynamic visitMemberGetExpr(MemberGetExpr expr) {
    var object = evaluateExpr(expr.collection);

    if (object is num) {
      object = HSVal_Number(object, expr.line, expr.column, this);
    } else if (object is bool) {
      object = HSVal_Boolean(object, expr.line, expr.column, this);
    } else if (object is String) {
      object = HSVal_String(object, expr.line, expr.column, this);
    } else if (object is List) {
      object = HSVal_List(object, expr.line, expr.column, this);
    } else if (object is Map) {
      object = HSVal_Map(object, expr.line, expr.column, this);
    }

    if ((object is HT_Instance) || (object is HT_Class)) {
      return object.fetch(expr.key.lexeme, expr.line, expr.column, this, from: curContext.fullName);
    }

    throw HSErr_Get(object.toString(), expr.line, expr.column, expr.fileName);
  }

  @override
  dynamic visitMemberSetExpr(MemberSetExpr expr) {
    dynamic object = evaluateExpr(expr.collection);
    var value = evaluateExpr(expr.value);
    if ((object is HT_Instance) || (object is HT_Class)) {
      object.assign(expr.key.lexeme, value, expr.line, expr.column, this, from: curContext.fullName);
      return value;
    }

    throw HSErr_Get(object.toString(), expr.key.line, expr.key.column, expr.fileName);
  }

  // TODO: import as 命名空间
  @override
  dynamic visitImportStmt(ImportStmt stmt) async {
    String file_loc;
    if (stmt.location.startsWith('hetu:')) {
      file_loc = env.sdkDirectory + stmt.location.substring(5) + '.ht';
    } else {
      file_loc = env.workingDirectory + stmt.location;
    }
    await evalf(file_loc, libName: stmt.nameSpace);
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    dynamic value;
    if (stmt.initializer != null) {
      value = evaluateExpr(stmt.initializer);
    }

    var decl_type = HT_Type();
    if (stmt.declType != null) {
      // TODO: 解析类型名，判断是否是class
      decl_type = stmt.declType;
    } else {
      // 从初始化表达式推断变量类型
      if (value != null) {
        decl_type = HT_TypeOf(value);
      }
    }

    curContext.define(stmt.name.lexeme, decl_type, stmt.name.line, stmt.name.column, this, value: value);
  }

  @override
  void visitExprStmt(ExprStmt stmt) => evaluateExpr(stmt.expr);

  @override
  void visitBlockStmt(BlockStmt stmt) {
    executeBlock(stmt.block, HT_Namespace(closure: curContext));
  }

  @override
  void visitReturnStmt(ReturnStmt stmt) {
    if (stmt.expr != null) {
      throw evaluateExpr(stmt.expr);
    }
    throw null;
  }

  @override
  void visitIfStmt(IfStmt stmt) {
    var value = evaluateExpr(stmt.condition);
    if (value is bool) {
      if (value) {
        evaluateStmt(stmt.thenBranch);
      } else if (stmt.elseBranch != null) {
        evaluateStmt(stmt.elseBranch);
      }
    } else {
      throw HSErr_Condition(stmt.condition.line, stmt.condition.column, stmt.condition.fileName);
    }
  }

  @override
  void visitWhileStmt(WhileStmt stmt) {
    var value = evaluateExpr(stmt.condition);
    if (value is bool) {
      while ((value is bool) && (value)) {
        try {
          evaluateStmt(stmt.loop);
          value = evaluateExpr(stmt.condition);
        } catch (error) {
          if (error is HT_Break) {
            return;
          } else if (error is HT_Continue) {
            continue;
          } else {
            throw error;
          }
        }
      }
    } else {
      throw HSErr_Condition(stmt.condition.line, stmt.condition.column, stmt.condition.fileName);
    }
  }

  @override
  void visitBreakStmt(BreakStmt stmt) {
    throw HT_Break();
  }

  @override
  void visitContinueStmt(ContinueStmt stmt) {
    throw HT_Continue();
  }

  @override
  void visitFuncStmt(FuncStmt stmt) {
    // 构造函数本身不注册为变量
    if (stmt.funcType != FuncStmtType.constructor) {
      HT_Function func;
      HT_External externFunc;
      if (stmt.isExtern) {
        externFunc = externs.fetch(stmt.name, stmt.keyword.line, stmt.keyword.column, this, from: externs.fullName);
      }
      func = HT_Function(stmt, name: stmt.internalName, extern: externFunc, declContext: curContext);
      curContext.define(stmt.name, func.typeid, stmt.keyword.line, stmt.keyword.column, this, value: func);
    }
  }

  @override
  void visitClassStmt(ClassStmt stmt) {
    HT_Class superClass;

    //TODO: while superClass != null, inherit all...

    if (stmt.name != env.lexicon.object) {
      if (stmt.superClass == null) {
        superClass = globals.fetch(env.lexicon.object, stmt.keyword.line, stmt.keyword.column, this);
      } else {
        superClass = globals.fetch(stmt.superClass.name, stmt.keyword.line, stmt.keyword.column, this);
      }
      if (superClass is! HT_Class) {
        throw HSErr_Extends(superClass.name, stmt.keyword.line, stmt.keyword.column, curFileName);
      }
    }

    var klass = HT_Class(stmt.name, superClass: superClass, closure: curContext);

    // 在开头就定义类本身的名字，这样才可以在类定义体中使用类本身
    curContext.define(stmt.name, HT_Type.CLASS, stmt.keyword.line, stmt.keyword.column, this, value: klass);

    var save = curContext;
    curContext = klass;
    for (var variable in stmt.variables) {
      if (variable.isStatic) {
        dynamic value;
        if (variable.initializer != null) {
          value = evaluateExpr(variable.initializer);
        } else if (variable.isExtern) {
          value = externs.fetch('${stmt.name}${env.lexicon.memberGet}${variable.name.lexeme}', variable.name.line,
              variable.name.column, this,
              from: externs.fullName);
        }

        var typeid = HT_Type();
        if (variable.declType != null) {
          // TODO: 解析类型名，判断是否是class
          typeid = variable.declType;
        } else {
          // 从初始化表达式推断变量类型
          if (value != null) {
            typeid = HT_TypeOf(value);
          }
        }

        klass.define(variable.name.lexeme, typeid, variable.name.line, variable.name.column, this, value: value);
      } else {
        klass.addVariable(variable);
      }
    }
    curContext = save;

    for (var method in stmt.methods) {
      if (klass.contains(method.internalName)) {
        throw HSErr_Defined(method.name, method.keyword.line, method.keyword.column, curFileName);
      }

      HT_Function func;
      HT_External externFunc;
      if (method.isExtern) {
        externFunc = externs.fetch('${stmt.name}${env.lexicon.memberGet}${method.internalName}', method.keyword.line,
            method.keyword.column, this,
            from: externs.fullName);
      }
      if (method.isStatic) {
        func = HT_Function(method, name: method.internalName, extern: externFunc, declContext: klass);
      } else {
        func = HT_Function(method, name: method.internalName, extern: externFunc);
      }
      klass.define(method.internalName, func.typeid, method.keyword.line, method.keyword.column, this, value: func);
    }
  }
}