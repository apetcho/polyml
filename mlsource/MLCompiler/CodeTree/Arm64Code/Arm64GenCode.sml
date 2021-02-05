(*
    Copyright (c) 2021 David C. J. Matthews

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    Licence version 2.1 as published by the Free Software Foundation.
    
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public Licence for more details.
    
    You should have received a copy of the GNU Lesser General Public
    Licence along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*)

functor Arm64GenCode (
    structure FallBackCG: GENCODESIG
    and       BackendTree: BackendIntermediateCodeSig
    and       CodeArray: CODEARRAYSIG
    and       Arm64Assembly: Arm64Assembly
    and       Debug: DEBUG
    
    sharing FallBackCG.Sharing = BackendTree.Sharing = CodeArray.Sharing = Arm64Assembly.Sharing
) : GENCODESIG =
struct

    open BackendTree CodeArray Arm64Assembly Address
    
    exception InternalError = Misc.InternalError
    
    (* tag a short constant *)
    fun tag c = 2 * c + 1
  
    (* shift a short constant, but don't set tag bit *)
    fun semitag c = 2 * c
    
    (* Remove items from the stack. If the second argument is true the value
       on the top of the stack has to be moved.
       TODO: This works only for offsets up to 256 words. *)
    fun resetStack(0, _, _) = ()
    |   resetStack(nItems, true, code) =
        (
            genPopReg(X0, code);
            resetStack(nItems, false, code);
            genPushReg(X0, code)
        )
    |   resetStack(nItems, false, code) =
            genAddRegConstant({sReg=X_MLStackPtr, dReg=X_MLStackPtr,
                cValue=Word.toInt wordSize * nItems}, code)

    (* Load a local value.  TODO: the offset is limited to 12-bits. *)
    fun genLocal(offset, code) =
        (loadRegAligned({dest=X0, base=X_MLStackPtr, wordOffset=offset}, code); genPushReg(X0, code))

    (* Load a value at an offset from the address on the top of the stack.
       TODO: the offset is limited to 12-bits. *)
    fun genIndirect(offset, code) =
        (genPopReg(X0, code); loadRegAligned({dest=X0, base=X0, wordOffset=offset}, code); genPushReg(X0, code))

    (* Sequence to allocate on the heap.  Returns the result in X0.  The words are not initialised
       apart from the length word. *)
    (*fun genAllocateFixedSize(words, flags, code) =
    let
        val label = createLabel()
    in
        genSubRegConstant({sReg=X_MLHeapAllocPtr, dReg=X0, cValue=(words+1)* Word.toInt wordSize}, code);
        genCompare(X0, X_MLHeapLimit, code);
        putBranchInstruction(condCarrySet, label, code);
        loadRegAligned({dest=X16, base=X_MLAssemblyInt, wordOffset=heapOverflowCallOffset}, code);
        genBranchAndLinkReg(X16, code);
        genRegisterMask([], code);
        genMoveRegToReg({sReg=X0, dReg=X_MLHeapAllocPtr}, code);
        setLabel(label, code);
        loadNonAddressConstant(X1,
            Word64.orb(Word64.fromInt words, Word64.<<(Word64.fromLarge(Word8.toLarge flags), 0w56)), code);
        storeRegUnaligned({dest=X1, base=X0, byteOffset= ~8}, code)
    end*)
    
    
    fun toDo() = raise Fallback

    fun genOpcode _ =  toDo()

    fun genSetHandler _ = toDo()

    fun genContainer _ = toDo()
    fun genSetStackVal _ =  toDo()
    fun genPushHandler _ =  toDo()
    fun genLdexc _ =  toDo()
    fun genCase _ =  toDo()
    fun genTuple _ =  toDo()
    fun genMoveToContainer _ =  toDo()
    fun genEqualWordConst _ =  toDo()
    fun genAllocMutableClosure _ =  toDo()
    fun genMoveToMutClosure _ =  toDo()
    fun genLock _ =  toDo()
    fun genClosure _ =  toDo()
    fun genIsTagged _ =  toDo()
    fun genDoubleToFloat _ =  toDo()
    fun genRealToInt _ =  toDo()
    fun genFloatToInt _ =  toDo()


    val opcode_notBoolean = 0
    val opcode_cellLength = 0
    and opcode_cellFlags = 0
    and opcode_clearMutable = 0
    and opcode_atomicExchAdd = 0
    and opcode_atomicReset = 0
    and opcode_longWToTagged = 0
    and opcode_signedToLongW = 0
    and opcode_unsignedToLongW = 0
    and opcode_realAbs = 0
    and opcode_realNeg = 0
    and opcode_fixedIntToReal = 0
    and opcode_fixedIntToFloat = 0
    and opcode_floatToReal = 0
    and opcode_floatAbs = 0
    and opcode_floatNeg = 0
    
    val opcode_equalWord = 0
    and opcode_lessSigned = 0
    and opcode_lessUnsigned = 0
    and opcode_lessEqSigned = 0
    and opcode_lessEqUnsigned = 0
    and opcode_greaterSigned = 0
    and opcode_greaterUnsigned = 0
    and opcode_greaterEqSigned = 0
    and opcode_greaterEqUnsigned = 0

    val opcode_fixedAdd = 0
    val opcode_fixedSub = 0
    val opcode_fixedMult = 0
    val opcode_fixedQuot = 0
    val opcode_fixedRem = 0
    val opcode_wordAdd = 0
    val opcode_wordSub = 0
    val opcode_wordMult = 0
    val opcode_wordDiv = 0
    val opcode_wordMod = 0
    val opcode_wordAnd = 0
    val opcode_wordOr = 0
    val opcode_wordXor = 0
    val opcode_wordShiftLeft = 0
    val opcode_wordShiftRLog = 0
    val opcode_wordShiftRArith = 0
    val opcode_allocByteMem = 0
    val opcode_lgWordEqual = 0
    val opcode_lgWordLess = 0
    val opcode_lgWordLessEq = 0
    val opcode_lgWordGreater = 0
    val opcode_lgWordGreaterEq = 0
    val opcode_lgWordAdd = 0
    val opcode_lgWordSub = 0
    val opcode_lgWordMult = 0
    val opcode_lgWordDiv = 0
    val opcode_lgWordMod = 0
    val opcode_lgWordAnd = 0
    val opcode_lgWordOr = 0
    val opcode_lgWordXor = 0
    val opcode_lgWordShiftLeft = 0
    val opcode_lgWordShiftRLog = 0
    val opcode_lgWordShiftRArith = 0
    val opcode_realEqual = 0
    val opcode_realLess = 0
    val opcode_realLessEq = 0
    val opcode_realGreater = 0
    val opcode_realGreaterEq = 0
    val opcode_realUnordered = 0
    val opcode_realAdd = 0
    val opcode_realSub = 0
    val opcode_realMult = 0
    val opcode_realDiv = 0
    val opcode_floatEqual = 0
    val opcode_floatLess = 0
    val opcode_floatLessEq = 0
    val opcode_floatGreater = 0
    val opcode_floatGreaterEq = 0
    val opcode_floatUnordered = 0
    val opcode_floatAdd = 0
    val opcode_floatSub = 0
    val opcode_floatMult = 0
    val opcode_floatDiv = 0
    val opcode_getThreadId = 0
    val opcode_allocWordMemory = 0
    val opcode_alloc_ref = 0
    val opcode_loadMLWord = 0
    val opcode_loadMLByte = 0
    val opcode_loadC8 = 0
    val opcode_loadC16 = 0
    val opcode_loadC32 = 0
    val opcode_loadC64 = 0
    val opcode_loadCFloat = 0
    val opcode_loadCDouble = 0
    val opcode_loadUntagged = 0
    val opcode_storeMLWord = 0
    val opcode_storeMLByte = 0
    val opcode_storeC8 = 0
    val opcode_storeC16 = 0
    val opcode_storeC32 = 0
    val opcode_storeC64 = 0
    val opcode_storeCFloat = 0
    val opcode_storeCDouble = 0
    val opcode_storeUntagged = 0
    val opcode_blockMoveWord = 0
    val opcode_blockMoveByte = 0
    val opcode_blockEqualByte = 0
    val opcode_blockCompareByte = 0
    val opcode_deleteHandler = 0
    val opcode_allocCSpace = 0
    val opcode_freeCSpace = 0
    val opcode_arbAdd = 0
    val opcode_arbSubtract = 0
    val opcode_arbMultiply = 0
    
    val SetHandler = 0

    type caseForm =
        {
            cases   : (backendIC * word) list,
            test    : backendIC,
            caseType: caseType,
            default : backendIC
        }
   
    (* Where the result, if any, should go *)
    datatype whereto =
        NoResult     (* discard result *)
    |   ToStack     (* Need a result but it can stay on the pseudo-stack *);
  
    (* Are we at the end of the function. *)
    datatype tail =
        EndOfProc
    |   NotEnd

    (* Code generate a function or global declaration *)
    fun codegen (pt, cvec, resultClosure, numOfArgs, localCount, parameters) =
    let
        datatype decEntry =
            StackAddr of int
        |   Empty
    
        val decVec = Array.array (localCount, Empty)
    
        (* Count of number of items on the stack. *)
        val realstackptr = ref 1 (* The closure ptr is already there *)
        
        (* Maximum size of the stack. *)
        val maxStack = ref 1

        (* Push a value onto the stack. *)
        fun incsp () =
        (
            realstackptr := !realstackptr + 1;
            if !realstackptr > !maxStack
            then maxStack := !realstackptr
            else ()
        )

        (* An entry has been removed from the stack. *)
        fun decsp () = realstackptr := !realstackptr - 1;
 
        fun pushLocalStackValue addr = ( genLocal(!realstackptr + addr, cvec); incsp() )

        (* generates code from the tree *)
        fun gencde (pt : backendIC, whereto : whereto, tailKind : tail, loopAddr) : unit =
        let
            (* Save the stack pointer value here. We may want to reset the stack. *)
            val oldsp = !realstackptr;

            (* Operations on ML memory always have the base as an ML address.
               Word operations are always word aligned.  The higher level will
               have extracted any constant offset and scaled it if necessary.
               That's helpful for the X86 but not for the interpreter.  We
               have to turn them back into indexes. *)
            fun genMLAddress({base, index, offset}, scale) =
            (
                gencde (base, ToStack, NotEnd, loopAddr);
                offset mod scale = 0 orelse raise InternalError "genMLAddress";
                case (index, offset div scale) of
                    (NONE, soffset) =>
                        (loadNonAddressConstant(X0, Word64.fromInt(tag soffset), cvec); genPushReg(X0, cvec); incsp())
                |   (SOME indexVal, 0) => gencde (indexVal, ToStack, NotEnd, loopAddr)
                |   (SOME indexVal, soffset) =>
                    (
                        gencde (indexVal, ToStack, NotEnd, loopAddr);
                        loadNonAddressConstant(X0, Word64.fromInt(tag soffset), cvec); genPushReg(X0, cvec); 
                        genOpcode(opcode_wordAdd, cvec)
                    )
           )
       
           (* Load the address, index value and offset for non-byte operations.
              Because the offset has already been scaled by the size of the operand
              we have to load the index and offset separately. *)
           fun genCAddress{base, index, offset} =
            (
                gencde (base, ToStack, NotEnd, loopAddr);
                case index of
                    NONE =>
                        (loadNonAddressConstant(X0, Word64.fromInt(tag 0), cvec); genPushReg(X0, cvec); incsp())
                |   SOME indexVal => gencde (indexVal, ToStack, NotEnd, loopAddr);
                loadNonAddressConstant(X0, Word64.fromInt(tag offset), cvec);
                genPushReg(X0, cvec); incsp()
            )

         val () =
           case pt of
                BICEval evl => genEval (evl, tailKind)

            |   BICExtract ext =>
                    (* This may just be being used to discard a value which isn't
                       used on this branch. *)
                if whereto = NoResult then ()
                else
                (
                    case ext of
                        BICLoadArgument locn =>
                            (* The register arguments appear in order on the
                               stack, followed by the stack argumens in reverse
                               order. *)
                            if locn < 8
                            then pushLocalStackValue (locn+1)
                            else pushLocalStackValue (numOfArgs-locn+8)
                    |   BICLoadLocal locn =>
                        (
                            case Array.sub (decVec, locn) of
                                StackAddr n => pushLocalStackValue (~ n)
                            |   _ => (* Should be on the stack, not a function. *)
                                raise InternalError "locaddr: bad stack address"
                        )
                    |   BICLoadClosure locn =>
                        (
                            pushLocalStackValue ~1; (* The closure itself. *)
                            genIndirect(locn+1 (* The first word is the code *), cvec)
                        )
                    |   BICLoadRecursive =>
                            pushLocalStackValue ~1 (* The closure itself - first value on the stack. *)
                )

            |   BICField {base, offset} =>
                    (gencde (base, ToStack, NotEnd, loopAddr); genIndirect (offset, cvec))

            |   BICLoadContainer {base, offset} =>
                    (gencde (base, ToStack, NotEnd, loopAddr); genIndirect (offset, cvec))
       
            |   BICLambda lam => genProc (lam, false, fn () => ())
           
            |   BICConstnt(w, _) =>
                    (
                        if isShort w
                        then loadNonAddressConstant(X0, Word64.fromInt(tag(Word.toIntX(toShort w))), cvec)
                        else loadAddressConstant(X0, w, cvec);
                        genPushReg(X0, cvec);
                        incsp()
                    )

            |   BICCond (testPart, thenPart, elsePart) =>
                    genCond (testPart, thenPart, elsePart, whereto, tailKind, loopAddr)
  
            |   BICNewenv(decls, exp) =>
                let         
                    (* Processes a list of entries. *)
            
                    (* Mutually recursive declarations. May be either lambdas or constants. Recurse down
                       the list pushing the addresses of the closure vectors, then unwind the 
                       recursion and fill them in. *)
                    fun genMutualDecs [] = ()

                    |   genMutualDecs ({lambda, addr, ...} :: otherDecs) =
                            genProc (lambda, true,
                                fn() =>
                                (
                                    Array.update (decVec, addr, StackAddr (! realstackptr));
                                    genMutualDecs (otherDecs)
                                ))

                    fun codeDecls(BICRecDecs dl) = genMutualDecs dl

                    |   codeDecls(BICDecContainer{size, addr}) =
                        (
                            (* If this is a container we have to process it here otherwise it
                               will be removed in the stack adjustment code. *)
                            genContainer(size, cvec); (* Push the address of this container. *)
                            realstackptr := !realstackptr + size + 1; (* Pushes N words plus the address. *)
                            Array.update (decVec, addr, StackAddr(!realstackptr))
                        )

                    |   codeDecls(BICDeclar{value, addr, ...}) =
                        (
                            gencde (value, ToStack, NotEnd, loopAddr);
                            Array.update (decVec, addr, StackAddr(!realstackptr))
                        )
                    |   codeDecls(BICNullBinding exp) = gencde (exp, NoResult, NotEnd, loopAddr)
                in
                    List.app codeDecls decls;
                    gencde (exp, whereto, tailKind, loopAddr)
                end
          
            |   BICBeginLoop {loop=body, arguments} =>
                (* Execute the body which will contain at least one Loop instruction.
                   There will also be path(s) which don't contain Loops and these
                   will drop through. *)
                let
                    val args = List.map #1 arguments
                    (* Evaluate each of the arguments, pushing the result onto the stack. *)
                    fun genLoopArg ({addr, value, ...}) =
                        (
                         gencde (value, ToStack, NotEnd, loopAddr);
                         Array.update (decVec, addr, StackAddr (!realstackptr));
                         !realstackptr (* Return the posn on the stack. *)
                        )
                    val argIndexList = map genLoopArg args;

                    val startSp = ! realstackptr; (* Remember the current top of stack. *)
                    val startLoop = createLabel ()
                    val () = setLabel(startLoop, cvec) (* Start of loop *)
                in
                    (* Process the body, passing the jump-back address down for the Loop instruction(s). *)
                    gencde (body, whereto, tailKind, SOME(startLoop, startSp, argIndexList))
                    (* Leave the arguments on the stack.  They can be cleared later if needed. *)
                end

            |   BICLoop argList => (* Jump back to the enclosing BeginLoop. *)
                let
                    val (startLoop, startSp, argIndexList) =
                        case loopAddr of
                            SOME l => l
                        |   NONE => raise InternalError "No BeginLoop for Loop instr"
                    (* Evaluate the arguments.  First push them to the stack because evaluating
                       an argument may depend on the current value of others.  Only when we've
                       evaluated all of them can we overwrite the original argument positions. *)
                    fun loadArgs ([], []) = !realstackptr - startSp (* The offset of all the args. *)
                      | loadArgs (arg:: argList, _ :: argIndexList) =
                        let
                            (* Evaluate all the arguments. *)
                            val () = gencde (arg, ToStack, NotEnd, NONE);
                            val argOffset = loadArgs(argList, argIndexList);
                        in
                            genSetStackVal(argOffset, cvec); (* Copy the arg over. *)
                            decsp(); (* The argument has now been popped. *)
                            argOffset
                        end
                      | loadArgs _ = raise InternalError "loadArgs: Mismatched arguments";

                    val _: int = loadArgs(List.map #1 argList, argIndexList)
                in
                    if !realstackptr <> startSp
                    then resetStack (!realstackptr - startSp, false, cvec) (* Remove any local variables. *)
                    else ();
            
                    (* Jump back to the start of the loop. *)
                    checkForInterrupts(X10, cvec);
                    
                    putBranchInstruction(condAlways, startLoop, cvec)
                end
  
            |   BICRaise exp =>
                (
                    gencde (exp, ToStack, NotEnd, loopAddr);
                    genPopReg(X0, cvec);
                    (* Copy the handler "register" into the stack pointer.  Then
                       jump to the address in the first word.  The second word is
                       the next handler.  This is set up in the handler.  We have a lot
                       more raises than handlers since most raises are exceptional conditions
                       such as overflow so it makes sense to minimise the code in each raise. *)
                    loadRegAligned({dest=X_MLStackPtr, base=X_MLAssemblyInt, wordOffset=exceptionHandlerOffset}, cvec);
                    loadRegAligned({dest=X1, base=X_MLStackPtr, wordOffset=0}, cvec);
                    genBranchRegister(X1, cvec)
                )
  
            |   BICHandle {exp, handler, exPacketAddr} =>
                let
                    (* Save old handler *)
                    val () = genPushHandler cvec
                    val () = incsp ()
                    val handlerLabel = createLabel()
                    val () = genSetHandler (SetHandler, handlerLabel, cvec)
                    val () = incsp()
                    (* Code generate the body; "NotEnd" because we have to come back
                     to remove the handler; "ToStack" because delHandler needs
                     a result to carry down. *)
                    val () = gencde (exp, ToStack, NotEnd, loopAddr)
      
                    (* Now get out of the handler and restore the old one. *)
                    val () = genOpcode(opcode_deleteHandler, cvec)
                    val skipHandler = createLabel()
                    val () = putBranchInstruction (condAlways, skipHandler, cvec)
                    val () = realstackptr := oldsp
                    val () = setLabel (handlerLabel, cvec)
                    (* Push the exception packet and set the address. *)
                    val () = genLdexc cvec
                    val () = incsp ()
                    val () = Array.update (decVec, exPacketAddr, StackAddr(!realstackptr))
                    val () = gencde (handler, ToStack, NotEnd, loopAddr)
                    (* Have to remove the exception packet. *)
                    val () = resetStack(1, true, cvec)
                    val () = decsp()
          
                    (* Finally fix-up the jump around the handler *)
                    val () = setLabel (skipHandler, cvec)
                in
                    ()
                end
  
            |   BICCase ({cases, test, default, firstIndex, ...}) =>
                let
                    val () = gencde (test, ToStack, NotEnd, loopAddr)
                    (* Label to jump to at the end of each case. *)
                    val exitJump = createLabel()

                    val () =
                        if firstIndex = 0w0 then ()
                        else
                        (   (* Subtract lower limit.  Don't check for overflow.  Instead
                               allow large value to wrap around and check in "case" instruction. *)
                            loadNonAddressConstant(X0, Word64.fromInt(tag(Word.toIntX firstIndex)), cvec);
                            genPushReg(X0, cvec);
                            genOpcode(opcode_wordSub, cvec)
                        )

                    (* Generate the case instruction followed by the table of jumps.  *)
                    val nCases = List.length cases
                    val caseLabels = genCase (nCases, cvec)
                    val () = decsp ()

                    (* The default case, if any, follows the case statement. *)
                    (* If we have a jump to the default set it to jump here. *)
                    local
                        fun fixDefault(NONE, defCase) = setLabel(defCase, cvec)
                        |   fixDefault(SOME _, _) = ()
                    in
                        val () = ListPair.appEq fixDefault (cases, caseLabels)
                    end
                    val () = gencde (default, whereto, tailKind, loopAddr);

                    fun genCases(SOME body, label) =
                        (
                            (* First exit from the previous case or the default if
                               this is the first. *)
                            putBranchInstruction(condAlways, exitJump, cvec);
                            (* Remove the result - the last case will leave it. *)
                            case whereto of ToStack => decsp () | NoResult => ();
                            (* Fix up the jump to come here. *)
                            setLabel(label, cvec);
                            gencde (body, whereto, tailKind, loopAddr)
                        )
                    |   genCases(NONE, _) = ()
                
                    val () = ListPair.appEq genCases (cases, caseLabels)
     
                    (* Finally set the exit jump to come here. *)
                    val () = setLabel (exitJump, cvec)
                in
                    ()
                end
  
            |   BICTuple recList =>
                let
                    val size = List.length recList
                in
                    (* Move the fields into the vector. *)
                    List.app(fn v => gencde (v, ToStack, NotEnd, loopAddr)) recList;
                    genTuple (size, cvec);
                    realstackptr := !realstackptr - (size - 1)
                end

            |   BICSetContainer{container, tuple, filter} =>
                (* Copy the contents of a tuple into a container.  If the tuple is a
                   Tuple instruction we can avoid generating the tuple and then
                   unpacking it and simply copy the fields that make up the tuple
                   directly into the container. *)
                (
                    case tuple of
                        BICTuple cl =>
                            (* Simply set the container from the values. *)
                        let
                            (* Load the address of the container. *)
                            val _ = gencde (container, ToStack, NotEnd, loopAddr);
                            fun setValues([], _, _) = ()

                            |   setValues(v::tl, sourceOffset, destOffset) =
                                if sourceOffset < BoolVector.length filter andalso BoolVector.sub(filter, sourceOffset)
                                then
                                (
                                    gencde (v, ToStack, NotEnd, loopAddr);
                                    (* Move the entry into the container. This instruction
                                       pops the value to be moved but not the destination. *)
                                    genMoveToContainer(destOffset, cvec);
                                    decsp();
                                    setValues(tl, sourceOffset+1, destOffset+1)
                                )
                                else setValues(tl, sourceOffset+1, destOffset)
                        in
                            setValues(cl, 0, 0)
                            (* The container address is still on the stack. *)
                        end

                    |   _ =>
                        let (* General case. *)
                            (* First the target tuple, then the container. *)
                            val () = gencde (tuple, ToStack, NotEnd, loopAddr)
                            val () = gencde (container, ToStack, NotEnd, loopAddr)
                            val last = BoolVector.foldli(fn (i, true, _) => i | (_, false, n) => n) ~1 filter

                            fun copy (sourceOffset, destOffset) =
                                if BoolVector.sub(filter, sourceOffset)
                                then
                                (
                                    (* Duplicate the tuple address . *)
                                    genLocal(1, cvec);
                                    genIndirect(sourceOffset, cvec);
                                    genMoveToContainer(destOffset, cvec);
                                    if sourceOffset = last
                                    then ()
                                    else copy (sourceOffset+1, destOffset+1)
                                )
                                else copy(sourceOffset+1, destOffset)
                        in
                            copy (0, 0)
                            (* The container and tuple addresses are still on the stack. *)
                        end
                )

            |   BICTagTest { test, tag, ... } =>
                (
                    gencde (test, ToStack, NotEnd, loopAddr);
                    genEqualWordConst(tag, cvec)
                )

            |   BICNullary {oper=BuiltIns.GetCurrentThreadId} =>
                (
                    genOpcode(opcode_getThreadId, cvec);
                    incsp()
                )

            |   BICNullary {oper=BuiltIns.CheckRTSException} =>
                ( (* Do nothing.  This is done in the RTS call. *)
                )

            |   BICNullary {oper=BuiltIns.CPUPause} =>
                ( (* Do nothing.  It's really only a hint. *)
                )

            |   BICUnary { oper, arg1 } =>
                let
                    open BuiltIns
                    val () = gencde (arg1, ToStack, NotEnd, loopAddr)
                in
                    case oper of
                        NotBoolean => genOpcode(opcode_notBoolean, cvec)
                    |   IsTaggedValue => genIsTagged cvec
                    |   MemoryCellLength => genOpcode(opcode_cellLength, cvec)
                    |   MemoryCellFlags => genOpcode(opcode_cellFlags, cvec)
                    |   ClearMutableFlag => genOpcode(opcode_clearMutable, cvec)
                    |   AtomicReset => genOpcode(opcode_atomicReset, cvec)
                    |   LongWordToTagged => genOpcode(opcode_longWToTagged, cvec)
                    |   SignedToLongWord => genOpcode(opcode_signedToLongW, cvec)
                    |   UnsignedToLongWord => genOpcode(opcode_unsignedToLongW, cvec)
                    |   RealAbs PrecDouble => genOpcode(opcode_realAbs, cvec)
                    |   RealNeg PrecDouble => genOpcode(opcode_realNeg, cvec)
                    |   RealFixedInt PrecDouble => genOpcode(opcode_fixedIntToReal, cvec)
                    |   RealAbs PrecSingle => genOpcode(opcode_floatAbs, cvec)
                    |   RealNeg PrecSingle => genOpcode(opcode_floatNeg, cvec)
                    |   RealFixedInt PrecSingle => genOpcode(opcode_fixedIntToFloat, cvec)
                    |   FloatToDouble => genOpcode(opcode_floatToReal, cvec)
                    |   DoubleToFloat rnding => genDoubleToFloat(rnding, cvec)
                    |   RealToInt (PrecDouble, rnding) => genRealToInt(rnding, cvec)
                    |   RealToInt (PrecSingle, rnding) => genFloatToInt(rnding, cvec)
                    |   TouchAddress => resetStack(1, false, cvec) (* Discard this *)
                    |   AllocCStack => genOpcode(opcode_allocCSpace, cvec)
                end

            |   BICBinary { oper=BuiltIns.WordComparison{test=BuiltIns.TestEqual, ...}, arg1, arg2=BICConstnt(w, _) } =>
                let
                    val () = gencde (arg1, ToStack, NotEnd, loopAddr)
                in
                    genEqualWordConst(toShort w, cvec)
                end

            |   BICBinary { oper=BuiltIns.WordComparison{test=BuiltIns.TestEqual, ...}, arg1=BICConstnt(w, _), arg2 } =>
                let
                    val () = gencde (arg2, ToStack, NotEnd, loopAddr)
                in
                    genEqualWordConst(toShort w, cvec)
                end

            |   BICBinary { oper, arg1, arg2 } =>
                let
                    open BuiltIns
                    val () = gencde (arg1, ToStack, NotEnd, loopAddr)
                    val () = gencde (arg2, ToStack, NotEnd, loopAddr)
                in
                    case oper of
                        WordComparison{test=TestEqual, ...} => genOpcode(opcode_equalWord, cvec)
                    |   WordComparison{test=TestLess, isSigned=true} => genOpcode(opcode_lessSigned, cvec)
                    |   WordComparison{test=TestLessEqual, isSigned=true} => genOpcode(opcode_lessEqSigned, cvec)
                    |   WordComparison{test=TestGreater, isSigned=true} => genOpcode(opcode_greaterSigned, cvec)
                    |   WordComparison{test=TestGreaterEqual, isSigned=true} => genOpcode(opcode_greaterEqSigned, cvec)
                    |   WordComparison{test=TestLess, isSigned=false} => genOpcode(opcode_lessUnsigned, cvec)
                    |   WordComparison{test=TestLessEqual, isSigned=false} => genOpcode(opcode_lessEqUnsigned, cvec)
                    |   WordComparison{test=TestGreater, isSigned=false} => genOpcode(opcode_greaterUnsigned, cvec)
                    |   WordComparison{test=TestGreaterEqual, isSigned=false} => genOpcode(opcode_greaterEqUnsigned, cvec)
                    |   WordComparison{test=TestUnordered, ...} => raise InternalError "WordComparison: TestUnordered"

                    |   PointerEq => genOpcode(opcode_equalWord, cvec)

                    |   FixedPrecisionArith ArithAdd => genOpcode(opcode_fixedAdd, cvec)
                    |   FixedPrecisionArith ArithSub => genOpcode(opcode_fixedSub, cvec)
                    |   FixedPrecisionArith ArithMult => genOpcode(opcode_fixedMult, cvec)
                    |   FixedPrecisionArith ArithQuot => genOpcode(opcode_fixedQuot, cvec)
                    |   FixedPrecisionArith ArithRem => genOpcode(opcode_fixedRem, cvec)
                    |   FixedPrecisionArith ArithDiv => raise InternalError "TODO: FixedPrecisionArith ArithDiv"
                    |   FixedPrecisionArith ArithMod => raise InternalError "TODO: FixedPrecisionArith ArithMod"

                    |   WordArith ArithAdd => genOpcode(opcode_wordAdd, cvec)
                    |   WordArith ArithSub => genOpcode(opcode_wordSub, cvec)
                    |   WordArith ArithMult => genOpcode(opcode_wordMult, cvec)
                    |   WordArith ArithDiv => genOpcode(opcode_wordDiv, cvec)
                    |   WordArith ArithMod => genOpcode(opcode_wordMod, cvec)
                    |   WordArith _ => raise InternalError "WordArith - unimplemented instruction"
                
                    |   WordLogical LogicalAnd => genOpcode(opcode_wordAnd, cvec)
                    |   WordLogical LogicalOr => genOpcode(opcode_wordOr, cvec)
                    |   WordLogical LogicalXor => genOpcode(opcode_wordXor, cvec)

                    |   WordShift ShiftLeft => genOpcode(opcode_wordShiftLeft, cvec)
                    |   WordShift ShiftRightLogical => genOpcode(opcode_wordShiftRLog, cvec)
                    |   WordShift ShiftRightArithmetic => genOpcode(opcode_wordShiftRArith, cvec)
                 
                    |   AllocateByteMemory => genOpcode(opcode_allocByteMem, cvec)
                
                    |   LargeWordComparison TestEqual => genOpcode(opcode_lgWordEqual, cvec)
                    |   LargeWordComparison TestLess => genOpcode(opcode_lgWordLess, cvec)
                    |   LargeWordComparison TestLessEqual => genOpcode(opcode_lgWordLessEq, cvec)
                    |   LargeWordComparison TestGreater => genOpcode(opcode_lgWordGreater, cvec)
                    |   LargeWordComparison TestGreaterEqual => genOpcode(opcode_lgWordGreaterEq, cvec)
                    |   LargeWordComparison TestUnordered => raise InternalError "LargeWordComparison: TestUnordered"
                
                    |   LargeWordArith ArithAdd => genOpcode(opcode_lgWordAdd, cvec)
                    |   LargeWordArith ArithSub => genOpcode(opcode_lgWordSub, cvec)
                    |   LargeWordArith ArithMult => genOpcode(opcode_lgWordMult, cvec)
                    |   LargeWordArith ArithDiv => genOpcode(opcode_lgWordDiv, cvec)
                    |   LargeWordArith ArithMod => genOpcode(opcode_lgWordMod, cvec)
                    |   LargeWordArith _ => raise InternalError "LargeWordArith - unimplemented instruction"

                    |   LargeWordLogical LogicalAnd => genOpcode(opcode_lgWordAnd, cvec)
                    |   LargeWordLogical LogicalOr => genOpcode(opcode_lgWordOr, cvec)
                    |   LargeWordLogical LogicalXor => genOpcode(opcode_lgWordXor, cvec)
                    |   LargeWordShift ShiftLeft => genOpcode(opcode_lgWordShiftLeft, cvec)
                    |   LargeWordShift ShiftRightLogical => genOpcode(opcode_lgWordShiftRLog, cvec)
                    |   LargeWordShift ShiftRightArithmetic => genOpcode(opcode_lgWordShiftRArith, cvec)

                    |   RealComparison (TestEqual, PrecDouble) => genOpcode(opcode_realEqual, cvec)
                    |   RealComparison (TestLess, PrecDouble) => genOpcode(opcode_realLess, cvec)
                    |   RealComparison (TestLessEqual, PrecDouble) => genOpcode(opcode_realLessEq, cvec)
                    |   RealComparison (TestGreater, PrecDouble) => genOpcode(opcode_realGreater, cvec)
                    |   RealComparison (TestGreaterEqual, PrecDouble) => genOpcode(opcode_realGreaterEq, cvec)
                    |   RealComparison (TestUnordered, PrecDouble) => genOpcode(opcode_realUnordered, cvec)

                    |   RealComparison (TestEqual, PrecSingle) => genOpcode(opcode_floatEqual, cvec)
                    |   RealComparison (TestLess, PrecSingle) => genOpcode(opcode_floatLess, cvec)
                    |   RealComparison (TestLessEqual, PrecSingle) => genOpcode(opcode_floatLessEq, cvec)
                    |   RealComparison (TestGreater, PrecSingle) => genOpcode(opcode_floatGreater, cvec)
                    |   RealComparison (TestGreaterEqual, PrecSingle) => genOpcode(opcode_floatGreaterEq, cvec)
                    |   RealComparison (TestUnordered, PrecSingle) => genOpcode(opcode_floatUnordered, cvec)

                    |   RealArith (ArithAdd, PrecDouble) => genOpcode(opcode_realAdd, cvec)
                    |   RealArith (ArithSub, PrecDouble) => genOpcode(opcode_realSub, cvec)
                    |   RealArith (ArithMult, PrecDouble) => genOpcode(opcode_realMult, cvec)
                    |   RealArith (ArithDiv, PrecDouble) => genOpcode(opcode_realDiv, cvec)

                    |   RealArith (ArithAdd, PrecSingle) => genOpcode(opcode_floatAdd, cvec)
                    |   RealArith (ArithSub, PrecSingle) => genOpcode(opcode_floatSub, cvec)
                    |   RealArith (ArithMult, PrecSingle) => genOpcode(opcode_floatMult, cvec)
                    |   RealArith (ArithDiv, PrecSingle) => genOpcode(opcode_floatDiv, cvec)

                    |   RealArith _ => raise InternalError "RealArith - unimplemented instruction"
                
                    |   FreeCStack => genOpcode(opcode_freeCSpace, cvec)
                
                    |   AtomicExchangeAdd => genOpcode(opcode_atomicExchAdd, cvec)
                     ;
                    decsp() (* Removes one item from the stack. *)
                end
            
            |   BICAllocateWordMemory {numWords as BICConstnt(length, _), flags as BICConstnt(flagByte, _), initial } =>
                if isShort length andalso toShort length = 0w1 andalso isShort flagByte andalso toShort flagByte = 0wx40
                then (* This is a very common case. *)
                (
                    gencde (initial, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_alloc_ref, cvec)
                )
                else
                let
                    val () = gencde (numWords, ToStack, NotEnd, loopAddr)
                    val () = gencde (flags, ToStack, NotEnd, loopAddr)
                    val () = gencde (initial, ToStack, NotEnd, loopAddr)
                in
                    genOpcode(opcode_allocWordMemory, cvec);
                    decsp(); decsp()
                end

            |   BICAllocateWordMemory { numWords, flags, initial } =>
                let
                    val () = gencde (numWords, ToStack, NotEnd, loopAddr)
                    val () = gencde (flags, ToStack, NotEnd, loopAddr)
                    val () = gencde (initial, ToStack, NotEnd, loopAddr)
                in
                    genOpcode(opcode_allocWordMemory, cvec);
                    decsp(); decsp()
                end

            |   BICLoadOperation { kind=LoadStoreMLWord _, address={base, index=NONE, offset}} =>
                (
                    (* If the index is a constant, frequently zero, we can use indirection.
                       The offset is a byte count so has to be divided by the word size but
                       it should always be an exact multiple. *)
                    gencde (base, ToStack, NotEnd, loopAddr);
                    offset mod Word.toInt wordSize = 0 orelse raise InternalError "gencde: BICLoadOperation - not word multiple";
                    genIndirect (offset div Word.toInt wordSize, cvec)
                )

            |   BICLoadOperation { kind=LoadStoreMLWord _, address} =>
                (
                    genMLAddress(address, Word.toInt wordSize);
                    genOpcode(opcode_loadMLWord, cvec);
                    decsp()
                )

            |   BICLoadOperation { kind=LoadStoreMLByte _, address} =>
                (
                    genMLAddress(address, 1);
                    genOpcode(opcode_loadMLByte, cvec);
                    decsp()
                )

            |   BICLoadOperation { kind=LoadStoreC8, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadC8, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreC16, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadC16, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreC32, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadC32, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreC64, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadC64, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreCFloat, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadCFloat, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreCDouble, address} =>
                (
                    genCAddress address;
                    genOpcode(opcode_loadCDouble, cvec);
                    decsp(); decsp()
                )

            |   BICLoadOperation { kind=LoadStoreUntaggedUnsigned, address} =>
                (
                    genMLAddress(address, Word.toInt wordSize);
                    genOpcode(opcode_loadUntagged, cvec);
                    decsp()
                )

            |   BICStoreOperation { kind=LoadStoreMLWord _, address, value } =>
                (
                    genMLAddress(address, Word.toInt wordSize);
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeMLWord, cvec);
                    decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreMLByte _, address, value } =>
                (
                    genMLAddress(address, 1);
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeMLByte, cvec);
                    decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreC8, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeC8, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreC16, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeC16, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreC32, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeC32, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreC64, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeC64, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreCFloat, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeCFloat, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreCDouble, address, value} =>
                (
                    genCAddress address;
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeCDouble, cvec);
                    decsp(); decsp(); decsp()
                )

            |   BICStoreOperation { kind=LoadStoreUntaggedUnsigned, address, value} =>
                (
                    genMLAddress(address, Word.toInt wordSize);
                    gencde (value, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_storeUntagged, cvec);
                    decsp(); decsp()
                )

            |   BICBlockOperation { kind=BlockOpMove{isByteMove=true}, sourceLeft, destRight, length } =>
                (
                    genMLAddress(sourceLeft, 1);
                    genMLAddress(destRight, 1);
                    gencde (length, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_blockMoveByte, cvec);
                    decsp(); decsp(); decsp(); decsp()
                )

            |   BICBlockOperation { kind=BlockOpMove{isByteMove=false}, sourceLeft, destRight, length } =>
                (
                    genMLAddress(sourceLeft, Word.toInt wordSize);
                    genMLAddress(destRight, Word.toInt wordSize);
                    gencde (length, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_blockMoveWord, cvec);
                    decsp(); decsp(); decsp(); decsp()
                )

            |   BICBlockOperation { kind=BlockOpEqualByte, sourceLeft, destRight, length } =>
                (
                    genMLAddress(sourceLeft, 1);
                    genMLAddress(destRight, 1);
                    gencde (length, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_blockEqualByte, cvec);
                    decsp(); decsp(); decsp(); decsp()
                )

            |   BICBlockOperation { kind=BlockOpCompareByte, sourceLeft, destRight, length } =>
                (
                    genMLAddress(sourceLeft, 1);
                    genMLAddress(destRight, 1);
                    gencde (length, ToStack, NotEnd, loopAddr);
                    genOpcode(opcode_blockCompareByte, cvec);
                    decsp(); decsp(); decsp(); decsp()
                )
       
           |    BICArbitrary { oper, arg1, arg2, ... } =>
                let
                    open BuiltIns
                    val () = gencde (arg1, ToStack, NotEnd, loopAddr)
                    val () = gencde (arg2, ToStack, NotEnd, loopAddr)
                in
                    case oper of
                        ArithAdd  => genOpcode(opcode_arbAdd, cvec)
                    |   ArithSub  => genOpcode(opcode_arbSubtract, cvec)
                    |   ArithMult => genOpcode(opcode_arbMultiply, cvec)
                    |   _ => raise InternalError "Unknown arbitrary precision operation";
                    decsp() (* Removes one item from the stack. *)
                end

        in (* body of gencde *) 

          (* This ensures that there is precisely one item on the stack if
             whereto = ToStack and no items if whereto = NoResult. *)
            case whereto of
                ToStack =>
                let
                    val newsp = oldsp + 1;
                    val adjustment = !realstackptr - newsp

                    val () =
                        if adjustment = 0
                        then ()
                        else if adjustment < ~1
                        then raise InternalError ("gencde: bad adjustment " ^ Int.toString adjustment)
                        (* Hack for declarations that should push values, but don't *)
                        else if adjustment = ~1
                        then
                        (
                            loadNonAddressConstant(X0, Word64.fromInt(tag 0), cvec);
                            genPushReg(X0, cvec)
                        )
                        else resetStack (adjustment, true, cvec)
                in
                    realstackptr := newsp
                end
          
            |   NoResult =>
                let
                    val adjustment = !realstackptr - oldsp

                    val () =
                        if adjustment = 0
                        then ()
                        else if adjustment < 0
                        then raise InternalError ("gencde: bad adjustment " ^ Int.toString adjustment)
                        else resetStack (adjustment, false, cvec)
                in
                    realstackptr := oldsp
                end
        end (* gencde *)

       (* doNext is only used for mutually recursive functions where a
         function may not be able to fill in its closure if it does not have
         all the remaining declarations. *)
        (* TODO: This always creates the closure on the heap even when makeClosure is false. *) 
       and genProc ({ closure=[], localCount, body, argTypes, name, ...}: bicLambdaForm, mutualDecs, doNext: unit -> unit) : unit =
            let
                (* Create a one word item for the closure.  This is returned for recursive references
                   and filled in with the address of the code when we've finished. *)
                val closure = makeConstantClosure()
                val newCode : code = codeCreate(name, parameters);

                (* Code-gen function. No non-local references. *)
                 val () =
                   codegen (body, newCode, closure, List.length argTypes, localCount, parameters);
                val () = loadAddressConstant(X0, closureAsAddress closure, cvec)
                val () = genPushReg(X0, cvec)
                val () = incsp();
            in
                if mutualDecs then doNext () else ()
            end

        |   genProc ({ localCount, body, name, argTypes, closure, ...}, mutualDecs, doNext) =
            let (* Full closure required. *)
                val resClosure = makeConstantClosure()
                val newCode = codeCreate (name, parameters)
                (* Code-gen function. *)
                val () = codegen (body, newCode, resClosure, List.length argTypes, localCount, parameters)
                val closureVars = List.length closure (* Size excluding the code address *)
            in
                if mutualDecs
                then
                let (* Have to make the closure now and fill it in later. *)
                    val () = loadAddressConstant(X0, toMachineWord resClosure, cvec)
                    val () = genPushReg(X0, cvec)
                    val () = genAllocMutableClosure(closureVars, cvec)
                    val () = incsp ()
           
                    val entryAddr : int = !realstackptr

                    val () = doNext () (* Any mutually recursive functions. *)

                    (* Push the address of the vector - If we have processed other
                       closures the vector will no longer be on the top of the stack. *)
                    val () = pushLocalStackValue (~ entryAddr)

                    (* Load items for the closure. *)
                    fun loadItems ([], _) = ()
                    |   loadItems (v :: vs, addr : int) =
                    let
                        (* Generate an item and move it into the clsoure *)
                        val () = gencde (BICExtract v, ToStack, NotEnd, NONE)
                        (* The closure "address" excludes the code address. *)
                        val () = genMoveToMutClosure(addr, cvec)
                        val () = decsp ()
                    in
                        loadItems (vs, addr + 1)
                    end
             
                    val () = loadItems (closure, 0)
                    val () = genLock cvec (* Lock it. *)
           
                    (* Remove the extra reference. *)
                    val () = resetStack (1, false, cvec)
                in
                    realstackptr := !realstackptr - 1
                end
         
                else
                let
                    (* Put it on the stack. *)
                    val () = loadAddressConstant(X0, toMachineWord resClosure, cvec)
                    val () = genPushReg(X0, cvec)
                    val () = incsp ()
                    val () = List.app (fn pt => gencde (BICExtract pt, ToStack, NotEnd, NONE)) closure
                    val () = genClosure (closureVars, cvec)
                in
                    realstackptr := !realstackptr - closureVars
                end
            end

        and genCond (testCode, thenCode, elseCode, whereto, tailKind, loopAddr) =
        let
            (* andalso and orelse are turned into conditionals with constants.
               Convert this into a series of tests. *)
            fun genTest(BICConstnt(w, _), jumpOn, targetLabel) =
                let
                    val cVal = case toShort w of 0w0 => false | 0w1 => true | _ => raise InternalError "genTest"
                in
                    if cVal = jumpOn
                    then putBranchInstruction (condAlways, targetLabel, cvec)
                    else ()
                end

            |   genTest(BICUnary { oper=BuiltIns.NotBoolean, arg1 }, jumpOn, targetLabel) =
                    genTest(arg1, not jumpOn, targetLabel)

            |   genTest(BICCond (testPart, thenPart, elsePart), jumpOn, targetLabel) =
                let
                    val toElse = createLabel() and exitJump = createLabel()
                in
                    genTest(testPart, false, toElse);
                    genTest(thenPart, jumpOn, targetLabel);
                    putBranchInstruction (condAlways, exitJump, cvec);
                    setLabel (toElse, cvec);
                    genTest(elsePart, jumpOn, targetLabel);
                    setLabel (exitJump, cvec)
                end

            |   genTest(testCode, jumpOn, targetLabel) =
                (
                    gencde (testCode, ToStack, NotEnd, loopAddr);
                    genPopReg(X0, cvec);
                    genSubSRegConstant({sReg=X0, dReg=XZero, cValue=tag 1, shifted=false}, cvec);
                    putBranchInstruction(if jumpOn then condEqual else condNotEqual, targetLabel, cvec);
                    decsp() (* conditional branch pops a value. *)
                )

            val toElse = createLabel() and exitJump = createLabel()
            val () = genTest(testCode, false, toElse)
            val () = gencde (thenCode, whereto, tailKind, loopAddr)
            (* Get rid of the result from the stack. If there is a result then the
            ``else-part'' will push it. *)
            val () = case whereto of ToStack => decsp () | NoResult => ()

            val () = putBranchInstruction (condAlways, exitJump, cvec)

            (* start of "else part" *)
            val () = setLabel (toElse, cvec)
            val () = gencde (elseCode, whereto, tailKind, loopAddr)
            val () = setLabel (exitJump, cvec)
        in
            ()
        end (* genCond *)

        and genEval (eval, tailKind : tail) : unit =
        let
            val argList : backendIC list = List.map #1 (#argList eval)
            val argsToPass : int = List.length argList;

            (* Load arguments *)
            fun loadArgs [] = ()
            |   loadArgs (v :: vs) =
            let (* Push each expression onto the stack. *)
                val () = gencde(v, ToStack, NotEnd, NONE)
            in
                loadArgs vs
            end;

            (* Have to guarantee that the expression to return the function
              is evaluated before the arguments. *)

            (* Returns true if evaluating it later is safe. *)
            fun safeToLeave (BICConstnt _) = true
            |   safeToLeave (BICLambda _) = true
            |   safeToLeave (BICExtract _) = true
            |   safeToLeave (BICField {base, ...}) = safeToLeave base
            |   safeToLeave (BICLoadContainer {base, ...}) = safeToLeave base
            |   safeToLeave _ = false

            val () =
                if (case argList of [] => true | _ => safeToLeave (#function eval))
                then
                let
                    (* Can load the args first. *)
                    val () = loadArgs argList
                in 
                    gencde (#function eval, ToStack, NotEnd, NONE)
                end

                else
                let
                    (* The expression for the function is too complicated to
                       risk leaving. It might have a side-effect and we must
                       ensure that any side-effects it has are done before the
                       arguments are loaded. *)
                    val () = gencde(#function eval, ToStack, NotEnd, NONE);
                    val () = loadArgs(argList);
                    (* Load the function again. *)
                    val () = genLocal(argsToPass, cvec);
                in
                    incsp ()
                end

        in (* body of genEval *)
            case tailKind of
                NotEnd => (* Normal call. *)
                let
                    val () = genPopReg(X8, cvec) (* Pop the closure pointer. *)
                    (* We need to put the first 8 arguments into registers and
                       leave the rest on the stack. *)
                    fun loadArg(n, reg) =
                        if argsToPass > n
                        then loadRegAligned({dest=reg, base=X_MLStackPtr, wordOffset=argsToPass-n-1}, cvec)
                        else ()
                    val () = loadArg(0, X0)
                    val () = loadArg(1, X1)
                    val () = loadArg(2, X2)
                    val () = loadArg(3, X3)
                    val () = loadArg(4, X4)
                    val () = loadArg(5, X5)
                    val () = loadArg(6, X6)
                    val () = loadArg(7, X7)
                in
                    loadRegAligned({dest=X9, base=X8, wordOffset=0}, cvec); (* Entry point *)
                    genBranchAndLinkReg(X9, cvec);
                    (* We have popped the closure pointer.  The caller has popped the stack
                       arguments and we have pushed the result value. The register arguments
                       are still on the stack. *)
                    genPushReg (X0, cvec);
                    realstackptr := !realstackptr - Int.max(argsToPass-8, 0) (* Args popped by caller. *)
                end
     
            |   EndOfProc => (* Tail recursive call. *)
                let
                    val () = genPopReg(X8, cvec) (* Pop the closure pointer. *)
                    val () = decsp()
                    (* Get the return address into X30. *)
                    val () = loadRegAligned({dest=X30, base=X_MLStackPtr, wordOffset= !realstackptr}, cvec)

                    (* Load the register arguments *)
                    fun loadArg(n, reg) =
                        if argsToPass > n
                        then loadRegAligned({dest=reg, base=X_MLStackPtr, wordOffset=argsToPass-n-1}, cvec)
                        else ()
                    val () = loadArg(0, X0)
                    val () = loadArg(1, X1)
                    val () = loadArg(2, X2)
                    val () = loadArg(3, X3)
                    val () = loadArg(4, X4)
                    val () = loadArg(5, X5)
                    val () = loadArg(6, X6)
                    val () = loadArg(7, X7)
                    (* We need to move the stack arguments into the original argument area. *)

                    (* This is the total number of words that this function is responsible for.
                       It includes the stack arguments that the caller expects to be removed. *)
                    val itemsOnStack = !realstackptr + 1 + numOfArgs

                    (* Stack arguments are moved using X9. *)
                    fun moveStackArg n =
                    if n < 8
                    then ()
                    else
                    let
                        val () = loadArg(n, X9)
                        val destOffset = itemsOnStack - (n-8) - 1
                        val () = storeRegAligned({dest=X9, base=X_MLStackPtr, wordOffset=destOffset}, cvec)
                    in
                        moveStackArg(n-1)
                    end

                    val () = moveStackArg (argsToPass-1)
                in
                    resetStack(itemsOnStack - Int.max(argsToPass-8, 0), false, cvec);
                    loadRegAligned({dest=X9, base=X8, wordOffset=0}, cvec); (* Entry point *)
                    genBranchRegister(X9, cvec)
                    (* Since we're not returning we can ignore the stack pointer value. *)
                end
        end

        (* Push the arguments passed in registers. *)
        val () = if numOfArgs >= 8 then genPushReg (X7, cvec) else ()
        val () = if numOfArgs >= 7 then genPushReg (X6, cvec) else ()
        val () = if numOfArgs >= 6 then genPushReg (X5, cvec) else ()
        val () = if numOfArgs >= 5 then genPushReg (X4, cvec) else ()
        val () = if numOfArgs >= 4 then genPushReg (X3, cvec) else ()
        val () = if numOfArgs >= 3 then genPushReg (X2, cvec) else ()
        val () = if numOfArgs >= 2 then genPushReg (X1, cvec) else ()
        val () = if numOfArgs >= 1 then genPushReg (X0, cvec) else ()
        val () = genPushReg (X30, cvec)
        val () = genPushReg (X8, cvec) (* Push closure pointer *)
        (* The stack check code will modify X30 if it has to call the
           RTS so this can only be done once X30 has been saved. *)
        val () = checkStackForFunction(X10, cvec)

       (* Generate the function. *)
       (* Assume we always want a result. There is otherwise a problem if the
          called routine returns a result of type void (i.e. no result) but the
          caller wants a result (e.g. the identity function). *)
        val () = gencde (pt, ToStack, EndOfProc, NONE)

        val () = genPopReg(X0, cvec) (* Value to return => pop into X0 *)
        val () = resetStack(1, false, cvec) (* Skip over the pushed closure *)
        val () = genPopReg(X30, cvec) (* Return address => pop into X30 *)
        val () = resetStack(numOfArgs, false, cvec) (* Remove the arguments *)
        val () = genReturnRegister(X30, cvec) (* Jump to X30 *)

    in (* body of codegen *)
       (* Having code-generated the body of the function, it is copied
          into a new data segment. *)
        generateCode{code = cvec, maxStack = !maxStack, resultClosure=resultClosure}
    end (* codegen *)

    fun gencodeLambda(lambda as { name, body, argTypes, localCount, ...}:bicLambdaForm, parameters, closure) =
    (let
        val debugSwitchLevel = Debug.getParameter Debug.compilerDebugTag parameters
        val _ = debugSwitchLevel <> 0 orelse raise Fallback
        (* make the code buffer for the new function. *)
        val newCode : code = codeCreate (name, parameters)
        (* This function must have no non-local references. *)
    in
        codegen (body, newCode, closure, List.length argTypes, localCount, parameters)
    end) handle Fallback => FallBackCG.gencodeLambda(lambda, parameters, closure)

    structure Foreign = FallBackCG.Foreign

    structure Sharing =
    struct
        open BackendTree.Sharing
        type closureRef = closureRef
    end

end;
