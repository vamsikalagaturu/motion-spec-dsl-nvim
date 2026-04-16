if exists('b:current_syntax')
  finish
endif

setlocal iskeyword+=-

syntax keyword motionSpecKeyword MOTION_SPEC CONSTRAINT_HANDLER MOVE CONTEXT WHEN WHILE UNTIL
syntax keyword motionSpecKeyword MOTION MONITORS CONTROLLERS PRIORITIES SOLVER
syntax keyword motionSpecContext Units World Pre Spec Post
syntax keyword motionSpecOperator keeping equal to greater than less between and is larger smaller
syntax keyword motionSpecOperator monitor trigger event set flag when while active apply at feed
syntax keyword motionSpecProperty outputs velocity-composition force-distribution configuration
syntax keyword motionSpecProperty cartesian-force joint-force constraint algorithm chain root gravity
syntax keyword motionSpecProperty level drivers of wrt ref-point as-seen-by
syntax keyword motionSpecProperty angular linear torque force rotation distance
syntax keyword motionSpecProperty x y z Kp Ki Kd decay velocity
syntax keyword motionSpecType VelocityTwist Wrench Pose KinematicChain Frame UniformGravitationalField
syntax keyword motionSpecType AngularVelocity LinearVelocity Force Torque LinearDistance Angle
syntax keyword motionSpecType PID VelocityCompositionSolver ForceDistributionSolver Vereshchagin NewtonEuler
syntax keyword motionSpecBuiltinValue acceleration cartesian base
syntax keyword motionSpecNs ns import

syntax match motionSpecIdent /[A-Za-z_][A-Za-z0-9_-]*/
syntax match motionSpecConstant /\<[A-Z][A-Z0-9_]*\>/ containedin=ALLBUT,motionSpecKeyword,motionSpecContext,motionSpecOperator,motionSpecProperty,motionSpecType,motionSpecBuiltinValue,motionSpecNs
syntax match motionSpecNumber /[-+]\?\(\d\+\(\.\d*\)\?\|\.\d\+\)\([eE][-+]\?\d\+\)\?/ nextgroup=motionSpecUnit skipwhite
syntax match motionSpecUnit /\v(rad\/s|m\/s2|m\/s|cm\/s|deg\/s|Nm|rad|deg|cm|m|N)/ contained
syntax region motionSpecString start=/"/ end=/"/ oneline
syntax match motionSpecComment /\/\/.*/

highlight default link motionSpecKeyword Keyword
highlight default link motionSpecContext Include
highlight default link motionSpecOperator Operator
highlight default link motionSpecProperty Special
highlight default link motionSpecType Type
highlight default link motionSpecBuiltinValue Constant
highlight default link motionSpecNs Include
highlight default link motionSpecConstant Constant
highlight default link motionSpecIdent Identifier
highlight default link motionSpecNumber Number
highlight default link motionSpecUnit SpecialChar
highlight default link motionSpecString String
highlight default link motionSpecComment Comment

let b:current_syntax = 'rob_mot'
