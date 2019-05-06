from Q import lua_runtime


def eval_lua(code):
    """
    evaluates the lua expressions using lupa's eval() method and returns the results

    Parameters:
        code: string representing lua expression

    Return:
        evaluated result
    """

    try:
        result = lua_runtime.eval(code)
    except Exception as exc:
        result = None
        print("Exception while evaluating lua code, \nError: {}".format(str(exc)))
    return result


def execute_lua(code):
    """
    executes the lua statements using lupa's execute() method and returns the results if any

    Parameters:
        code: string representing lua statements

    Return:
        output of lupa's execute() method
    """

    try:
        result = lua_runtime.execute(code)
    except Exception as exc:
        print("Exception while executing lua code, \nError: {}".format(str(exc)))
        result = None
    return result