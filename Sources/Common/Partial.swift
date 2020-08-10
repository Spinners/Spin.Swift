//
//  Partial.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-10.
//

enum Partial {
    case undefined
}

func partial<Arg1, Result>(_ block: @escaping (Arg1) -> Result,
                           arg1: Arg1) -> () -> Result {
    return {
        block(arg1)
    }
}

func partial<Arg1, Arg2, Result>(_ block: @escaping (Arg1, Arg2) -> Result,
                                 arg1: Arg1,
                                 arg2: Partial) -> (Arg2) -> Result {
    return { futureArg2 in
        block(arg1, futureArg2)
    }
}

func partial<Arg1, Arg2, Result>(_ block: @escaping (Arg1, Arg2) -> Result,
                                 arg1: Partial,
                                 arg2: Arg2) -> (Arg1) -> Result {
    return { futureArg1 in
        block(futureArg1, arg2)
    }
}

func partial<Arg1, Arg2, Arg3, Result>(_ block: @escaping (Arg1, Arg2, Arg3) -> Result,
                                       arg1: Arg1,
                                       arg2: Arg2,
                                       arg3: Partial) -> (Arg3) -> Result {
    return { futureArg3 in
        block(arg1, arg2, futureArg3)
    }
}

func partial<Arg1, Arg2, Arg3, Result>(_ block: @escaping (Arg1, Arg2, Arg3) -> Result,
                                       arg1: Arg1,
                                       arg2: Partial,
                                       arg3: Arg3) -> (Arg2) -> Result {
    return { futureArg2 in
        block(arg1, futureArg2, arg3)
    }
}

func partial<Arg1, Arg2, Arg3, Result>(_ block: @escaping (Arg1, Arg2, Arg3) -> Result,
                                       arg1: Partial,
                                       arg2: Arg2,
                                       arg3: Arg3) -> (Arg1) -> Result {
    return { futureArg1 in
        block(futureArg1, arg2, arg3)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4) -> Result,
                                             arg1: Arg1,
                                             arg2: Arg2,
                                             arg3: Arg3,
                                             arg4: Partial) -> (Arg4) -> Result {
    return { futureArg4 in
        block(arg1, arg2, arg3, futureArg4)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4) -> Result,
                                             arg1: Arg1,
                                             arg2: Arg2,
                                             arg3: Partial,
                                             arg4: Arg4) -> (Arg3) -> Result {
    return { futureArg3 in
        block(arg1, arg2, futureArg3, arg4)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4) -> Result,
                                             arg1: Arg1,
                                             arg2: Partial,
                                             arg3: Arg3,
                                             arg4: Arg4) -> (Arg2) -> Result {
    return { futureArg2 in
        block(arg1, futureArg2, arg3, arg4)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4) -> Result,
                                             arg1: Partial,
                                             arg2: Arg2,
                                             arg3: Arg3,
                                             arg4: Arg4) -> (Arg1) -> Result {
    return { futureArg1 in
        block(futureArg1, arg2, arg3, arg4)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Arg5, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4, Arg5) -> Result,
                                             arg1: Arg1,
                                             arg2: Arg2,
                                             arg3: Arg3,
                                             arg4: Arg4,
                                             arg5: Partial) -> (Arg5) -> Result {
    return { futureArg5 in
        block(arg1, arg2, arg3, arg4, futureArg5)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Arg5, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4, Arg5) -> Result,
                                             arg1: Arg1,
                                             arg2: Arg2,
                                             arg3: Arg3,
                                             arg4: Partial,
                                             arg5: Arg5) -> (Arg4) -> Result {
    return { futureArg4 in
        block(arg1, arg2, arg3, futureArg4, arg5)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Arg5, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4, Arg5) -> Result,
                                             arg1: Arg1,
                                             arg2: Arg2,
                                             arg3: Partial,
                                             arg4: Arg4,
                                             arg5: Arg5) -> (Arg3) -> Result {
    return { futureArg3 in
        block(arg1, arg2, futureArg3, arg4, arg5)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Arg5, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4, Arg5) -> Result,
                                             arg1: Arg1,
                                             arg2: Partial,
                                             arg3: Arg3,
                                             arg4: Arg4,
                                             arg5: Arg5) -> (Arg2) -> Result {
    return { futureArg2 in
        block(arg1, futureArg2, arg3, arg4, arg5)
    }
}

func partial<Arg1, Arg2, Arg3, Arg4, Arg5, Result>(_ block: @escaping (Arg1, Arg2, Arg3, Arg4, Arg5) -> Result,
                                             arg1: Partial,
                                             arg2: Arg2,
                                             arg3: Arg3,
                                             arg4: Arg4,
                                             arg5: Arg5) -> (Arg1) -> Result {
    return { futureArg1 in
        block(futureArg1, arg2, arg3, arg4, arg5)
    }
}
