if exists('b:current_syntax')
  finish
endif

setlocal iskeyword+=-

" Keep this fallback structural.  Only true reserved words are listed here;
" model-specific types, algorithms, quantities, controllers, and solvers are
" highlighted by position.
syntax keyword motionSpecKeyword ROBOT MOTION_SPEC CONSTRAINT_HANDLER MOVE CONTEXT
syntax keyword motionSpecKeyword WHEN WHILE UNTIL MOTION MONITORS CONTROLLERS SOLVERS
syntax keyword motionSpecKeyword World Pre Spec Post Solver PID
syntax keyword motionSpecKeyword ns import

syntax keyword motionSpecOperator keeping equal to greater than less between and
syntax keyword motionSpecOperator is larger smaller monitor trigger event set flag
syntax keyword motionSpecOperator when while active as apply at

syntax keyword motionSpecProperty type urdf base manipulators chain root end
syntax keyword motionSpecProperty constraint solver algorithm robot gravity
syntax keyword motionSpecProperty of wrt ref-point as-seen-by x y z Kp Ki Kd decay

syntax match motionSpecDeclName /^\s*\zs[A-Za-z_][A-Za-z0-9_-]*\ze\s*:/
syntax match motionSpecType /\%(:\s*\)\@<=[A-Za-z_][A-Za-z0-9_-]*\>/ containedin=ALLBUT,motionSpecComment,motionSpecString
syntax match motionSpecMember /\.[A-Za-z_][A-Za-z0-9_-]*\>/ containedin=ALLBUT,motionSpecComment,motionSpecString
syntax match motionSpecNumber /[-+]\?\(\d\+\(\.\d*\)\?\|\.\d\+\)\([eE][-+]\?\d\+\)\?/ nextgroup=motionSpecUnit skipwhite
syntax match motionSpecUnit /\v(rad\/s|m\/s2|m\/s|cm\/s|deg\/s|Nm|rad|deg|cm|m|N)/ contained
syntax region motionSpecString start=/"/ end=/"/ oneline
syntax match motionSpecComment /\/\/.*/

highlight default link motionSpecKeyword Keyword
highlight default link motionSpecOperator Operator
highlight default link motionSpecProperty Special
highlight default link motionSpecDeclName Identifier
highlight default link motionSpecType Type
highlight default link motionSpecMember Identifier
highlight default link motionSpecNumber Number
highlight default link motionSpecUnit SpecialChar
highlight default link motionSpecString String
highlight default link motionSpecComment Comment

let b:current_syntax = 'rob_mot'
