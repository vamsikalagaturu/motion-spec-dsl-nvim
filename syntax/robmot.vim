if exists('b:current_syntax')
  finish
endif

setlocal iskeyword+=-

" Section keywords
syntax keyword motionSpecKeyword ROBOT MOTION_SPEC CONSTRAINT_HANDLER MOVE CONTEXT
syntax keyword motionSpecKeyword WHEN WHILE UNTIL MOTION MONITORS CONTROLLERS SOLVERS
syntax keyword motionSpecKeyword ns import

" Context type modifiers
syntax keyword motionSpecContextType World Pre Spec Post

" DSL type names: always Type regardless of position
syntax keyword motionSpecType Manipulator MobileBase MobileManipulator
syntax keyword motionSpecType VelocityTwist Wrench Pose KinematicChain Frame Link Gravity
syntax keyword motionSpecType AngularVelocity LinearVelocity Force Torque
syntax keyword motionSpecType LinearDistance AngularDistance Angle AngularDistance Vector
syntax keyword motionSpecType Vereshchagin NewtonEuler VelocityDistribution ForceDistribution
syntax keyword motionSpecType PID Solver

" Constraint / expression operators
syntax keyword motionSpecOperator keeping equal to greater than less between and
syntax keyword motionSpecOperator is larger smaller as apply at

" Monitor operators
syntax keyword motionSpecOperator monitor trigger event set flag when while active

" Struct field keywords
syntax keyword motionSpecProperty type urdf base manipulators chain root end
syntax keyword motionSpecProperty constraint solver algorithm robot gravity
syntax keyword motionSpecProperty x y z Kp Ki Kd decay

" Geometric property keys
syntax keyword motionSpecAttribute of wrt ref-point as-seen-by

" Subspace and axis literals inside a view
syntax match motionSpecSubspace /\.\zs\(angvel\|linvel\|torque\|force\|orientation\|position\)\ze[.}]/
syntax match motionSpecAxis /\.\zs[xyz]\ze[>,]/

" <...> references: the whole <path> is a reference, angle brackets included.
syntax region motionSpecRef start=/</ end=/>/ oneline
  \ contains=motionSpecRefPath,motionSpecRefDot

syntax match motionSpecRefPath /[A-Za-z_][A-Za-z0-9_-]*/ contained
syntax match motionSpecRefDot /\./ contained

" Inline context_ref with value override: [scope.var = value unit]
syntax region motionSpecInlineRef start=/\[/ end=/\]/ oneline
  \ contains=motionSpecRefPath,motionSpecRefDot,motionSpecNumber,motionSpecUnit

" Inline value declaration inside Spec[...] / Pre[...] / Post[...]
" (the scope word before the [ is already caught by motionSpecContextType)

" Declaration names: identifier immediately before ':'
syntax match motionSpecDeclName /\<[A-Za-z_][A-Za-z0-9_-]*\ze\s*:/

" Numbers (word boundary so digits in names like c1 are not matched)
syntax match motionSpecNumber /\<[-+]\?\(\d\+\(\.\d*\)\?\|\.\d\+\)\([eE][-+]\?\d\+\)\?\>/ nextgroup=motionSpecUnit skipwhite

syntax match motionSpecUnit /\v(rad\/s|m\/s2|m\/s|cm\/s|deg\/s|Nm|rad|deg|cm|m|N)\ze(\s|,|>|\])/ contained

syntax region motionSpecString start=/"/ end=/"/ oneline
syntax match motionSpecComment /\/\/.*/

highlight default link motionSpecKeyword     Keyword
highlight default link motionSpecContextType PreProc
highlight default link motionSpecOperator    Operator
highlight default link motionSpecProperty    Special
highlight default link motionSpecAttribute   Function
highlight default link motionSpecType        Type
highlight default link motionSpecDeclName    Identifier
highlight default link motionSpecSubspace    Function
highlight default link motionSpecAxis        Constant
highlight default link motionSpecNumber      Number
highlight default link motionSpecUnit        SpecialChar
highlight default link motionSpecString      String
highlight default link motionSpecComment     Comment
highlight default link motionSpecRef         Special
highlight default link motionSpecRefPath     Identifier
highlight default link motionSpecRefDot      Delimiter
highlight default link motionSpecInlineRef   Special

let b:current_syntax = 'robmot'
