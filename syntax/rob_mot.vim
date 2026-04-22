if exists('b:current_syntax')
  finish
endif

setlocal iskeyword+=-

" Keep this fallback structural.  Only true reserved words are listed here;
" model-specific types, algorithms, quantities, controllers, and solvers are
" highlighted by position.
syntax keyword motionSpecKeyword ROBOT MOTION_SPEC CONSTRAINT_HANDLER MOVE CONTEXT
syntax keyword motionSpecKeyword WHEN WHILE UNTIL MOTION MONITORS CONTROLLERS SOLVERS
syntax keyword motionSpecKeyword World Pre Spec Post
syntax keyword motionSpecKeyword ns import

syntax keyword motionSpecOperator keeping equal to greater than less between and
syntax keyword motionSpecOperator is larger smaller monitor trigger event set flag
syntax keyword motionSpecOperator when while active as apply at

syntax keyword motionSpecProperty type urdf base manipulators chain root end
syntax keyword motionSpecProperty constraint solver algorithm robot gravity
syntax keyword motionSpecProperty x y z Kp Ki Kd decay
syntax keyword motionSpecAttribute of wrt ref-point as-seen-by

" DSL-defined type names: always highlighted as Type regardless of position.
syntax keyword motionSpecType Manipulator MobileBase MobileManipulator
syntax keyword motionSpecType VelocityTwist Wrench Pose KinematicChain Frame Link Gravity
syntax keyword motionSpecType AngularVelocity LinearVelocity Force Torque LinearDistance AngularDistance Vector
syntax keyword motionSpecType Vereshchagin NewtonEuler VelocityDistribution ForceDistribution
syntax keyword motionSpecType PID Solver

syntax match motionSpecDeclName /^\s*\zs[A-Za-z_][A-Za-z0-9_-]*\ze\s*:/
syntax match motionSpecMember /\.[A-Za-z_][A-Za-z0-9_-]*\>/ containedin=ALLBUT,motionSpecComment,motionSpecString
syntax match motionSpecSubspace /\.\zs\(angvel\|linvel\|torque\|force\|orientation\|position\)\ze\./ containedin=ALLBUT,motionSpecComment,motionSpecString
syntax match motionSpecAxis /\.\zs[xyz]\>/ containedin=ALLBUT,motionSpecComment,motionSpecString
" \< requires a word boundary before the number so digits inside identifiers
" such as c1 or c2 are not matched.
syntax match motionSpecNumber /\<[-+]\?\(\d\+\(\.\d*\)\?\|\.\d\+\)\([eE][-+]\?\d\+\)\?/ nextgroup=motionSpecUnit skipwhite
syntax match motionSpecUnit /\v(rad\/s|m\/s2|m\/s|cm\/s|deg\/s|Nm|rad|deg|cm|m|N)/ contained
syntax region motionSpecString start=/"/ end=/"/ oneline
syntax match motionSpecComment /\/\/.*/

highlight default link motionSpecKeyword Keyword
highlight default link motionSpecOperator Operator
highlight default link motionSpecProperty Special
highlight default link motionSpecAttribute Identifier
highlight default link motionSpecDeclName Identifier
highlight default link motionSpecType Type
highlight default link motionSpecMember Identifier
highlight default link motionSpecSubspace Function
highlight default link motionSpecAxis Constant
highlight default link motionSpecNumber Number
highlight default link motionSpecUnit SpecialChar
highlight default link motionSpecString String
highlight default link motionSpecComment Comment

let b:current_syntax = 'rob_mot'
