grammar SCP;

WHITESPACE: [ \t\r\n]+ -> skip;
NUMBER:'number';
UNARY_RELATION_RIGHT:'->';
UNARY_RELATION_LEFT:'<-';
BINARY_RELATION_RIGHT:'=>';
BINARY_RELATION_LEFT:'<=';
END_POINT:';;';
BLOCK_START:'(*';
BLOCK_END:'*)';
EMPTY_CIRCLE_WITH_NAME:'..';



NREL:'nrel_';
NREL_ITERATION_VAR:NREL'iteration_variable';
NREL_VALUE: NREL 'value';
NREL_CONDITION:NREL 'condition';
NREL_RETURN_VALUE: NREL 'return_value';
NREL_RETURN_TYPE: NREL 'return_type';
NREL_FUNCTION_PROTOTYPE: NREL 'function_prototype';
NREL_ARGUMENT: NREL 'argument';
NREL_ITERATION_CHANGE: NREL 'iteration_change';
NREL_ITERATION_BODY: NREL 'iteration_body';
NREL_INTERRUPT: NREL'interrupt';
NREL_CLASS_FIELD: NREL 'class_field';
NREL_CALLER: NREL 'caller';
NREL_CONSTRUCTOR: NREL 'constructor';
NREL_BODY: NREL 'body';
NREL_ACCESS_MODIFIER: NREL 'access_modifier';
NREL_METHOD: NREL 'method';
NREL_IMPLEMENTS: NREL 'implements';
NREL_EXTENDS: NREL 'extends';
NREL_BRANCHING: NREL 'branching';
NREL_KEYWORD: NREL 'keywords';



CONCEPT_VARIABLE: CONCEPT'variable';
CONCEPT_METHOD: CONCEPT 'method';
CONCEPT_ACCESS_MODIFIER: CONCEPT 'access_modifier_' ('private'|'public'|'protected');
CONCEPT_WHILE: CONCEPT 'while';
CONCEPT_CHILD_CLASS: CONCEPT 'child_class';
CONCEPT_CHILD_INTERFACE: CONCEPT 'child_interface';
CONCEPT_IF_ELSE: CONCEPT 'if_else';
CODE_BLOCK:CONCEPT'code_block';
FOR:CONCEPT'for';
BREAK:CONCEPT'break';
CONCEPT_CALLED_METHOD: CONCEPT CALLED_METHOD;
CALLED_METHOD:'called_method';
CONCEPT_ARGUMENT: CONCEPT 'argument''s'?;
CONCEPT_ITERATION_STATEMENT: CONCEPT'iteration_statement';
CONCEPT_CLASS: CONCEPT 'class';
CONCEPT_INTERFACE: CONCEPT 'interface';
CONCEPT: 'concept_';
CLASS: 'class_';
CONSTRUCTOR: 'constructor_';


OPERATOR:'operator_';
OPERATOR_LESS:OPERATOR 'less';
OPERATOR_DECREMENT:OPERATOR 'decrement';
ROLE: 'rrel_'(NAME|NUM);
OPERATOR_NODE: OPERATOR ;
CLASS_NODE: EMPTY_CIRCLE_WITH_NAME?(CLASS NAME ('_' NAME)?);//TODO maybe add interface node
CONSTRUCTOR_NODE:EMPTY_CIRCLE_WITH_NAME?(CONSTRUCTOR NAME '_'  NAME );
NODE: EMPTY_CIRCLE_WITH_NAME?(NAME | NUM)|EMPTY_CIRCLE;
NUM:[0-9]+;
EMPTY_CIRCLE:'...';
DVOETOCHIE: ':';
NAME:([a-z]|[A-Z])+;


type:
    'integer' |
    'string'  |
    'float'   |
    'void'
;

operators:
     OPERATOR_LESS
    | OPERATOR_DECREMENT
    | OPERATOR 'equal'
    | OPERATOR 'division'
    | OPERATOR 'addition' //*
    | OPERATOR 'plus'
    | OPERATOR 'minus'
    | OPERATOR 'equality'
    | OPERATOR 'more'//TODO MORE
;

keywords:
    'static'   |
    'final'    |
    'override' |
;

iteration_variable:NREL_ITERATION_VAR DVOETOCHIE NODE
              BLOCK_START UNARY_RELATION_LEFT CONCEPT_VARIABLE END_POINT
              BINARY_RELATION_RIGHT NREL_VALUE DVOETOCHIE NODE
              BLOCK_START UNARY_RELATION_LEFT NUMBER END_POINT BLOCK_END END_POINT BLOCK_END END_POINT
;

role:(UNARY_RELATION_RIGHT ROLE DVOETOCHIE NODE END_POINT);

condition:(BINARY_RELATION_RIGHT NREL_CONDITION DVOETOCHIE NODE BLOCK_START BINARY_RELATION_LEFT
NREL_RETURN_VALUE DVOETOCHIE NODE
BLOCK_START UNARY_RELATION_LEFT CALLED_METHOD END_POINT
BINARY_RELATION_RIGHT NREL_FUNCTION_PROTOTYPE DVOETOCHIE operators END_POINT
BINARY_RELATION_RIGHT NREL_ARGUMENT DVOETOCHIE NODE
BLOCK_START  UNARY_RELATION_LEFT  CONCEPT_ARGUMENT END_POINT
role+
BLOCK_END END_POINT
BLOCK_END END_POINT
BLOCK_END END_POINT)
|
(BINARY_RELATION_RIGHT NREL_CONDITION DVOETOCHIE NODE
BLOCK_START
UNARY_RELATION_LEFT CONCEPT_VARIABLE END_POINT
BLOCK_END END_POINT)
;

iteration_change: BINARY_RELATION_RIGHT NREL_ITERATION_CHANGE DVOETOCHIE NODE
BLOCK_START
 UNARY_RELATION_LEFT CALLED_METHOD END_POINT
 BINARY_RELATION_RIGHT NREL_FUNCTION_PROTOTYPE DVOETOCHIE operators END_POINT
 BINARY_RELATION_RIGHT NREL_ARGUMENT DVOETOCHIE NODE
 BLOCK_START
 UNARY_RELATION_LEFT CONCEPT_ARGUMENT END_POINT
 UNARY_RELATION_RIGHT ROLE DVOETOCHIE NODE END_POINT
 BLOCK_END END_POINT
 BLOCK_END END_POINT;

iteration_body: BINARY_RELATION_RIGHT NREL_ITERATION_BODY DVOETOCHIE NODE
BLOCK_START (UNARY_RELATION_LEFT code END_POINT)* BLOCK_END END_POINT;//TODO body with break continue and without


for_satement:
NODE BLOCK_START
UNARY_RELATION_LEFT FOR END_POINT BINARY_RELATION_RIGHT  iteration_variable condition iteration_change iteration_body
;

while_statement:
    NODE
    BLOCK_START
        UNARY_RELATION_LEFT CONCEPT_WHILE END_POINT
        condition
        body
    BLOCK_END END_POINT
;

if_branching_statement:
    NODE
    BLOCK_START
    UNARY_RELATION_LEFT CONCEPT_IF_ELSE END_POINT
    condition?
    body
    (BINARY_RELATION_RIGHT NREL_BRANCHING DVOETOCHIE if_branching_statement)*
    BLOCK_END END_POINT
;

break_rule: NODE
     BLOCK_START UNARY_RELATION_LEFT BREAK END_POINT
     BLOCK_END END_POINT
;

class_statement:
    CONCEPT_CLASS UNARY_RELATION_RIGHT CLASS_NODE
    BLOCK_START
    (BINARY_RELATION_RIGHT NREL_EXTENDS DVOETOCHIE CLASS_NODE
    BLOCK_START UNARY_RELATION_LEFT CONCEPT_CHILD_CLASS BLOCK_END END_POINT)?
    (BINARY_RELATION_RIGHT NREL_IMPLEMENTS DVOETOCHIE CLASS_NODE
    BLOCK_START UNARY_RELATION_LEFT CONCEPT_CHILD_INTERFACE BLOCK_END END_POINT)?
    add_keyword*
    ( class_field
    | class_constructor
    | method_statement
    )*
    BLOCK_END END_POINT
;

interface_statement:
    CONCEPT_INTERFACE UNARY_RELATION_RIGHT CLASS_NODE
    BLOCK_START
    (BINARY_RELATION_RIGHT NREL_IMPLEMENTS DVOETOCHIE CLASS_NODE
    BLOCK_START UNARY_RELATION_LEFT CONCEPT_CHILD_INTERFACE BLOCK_END END_POINT)?
    add_keyword*
    method_statement
    BLOCK_END END_POINT
;

class_field:
    BINARY_RELATION_RIGHT NREL_CLASS_FIELD DVOETOCHIE
    CLASS_NODE
    BLOCK_START
        ((UNARY_RELATION_LEFT CONCEPT_VARIABLE //TODO unique somehow
        | UNARY_RELATION_LEFT CONCEPT type
        | BINARY_RELATION_RIGHT NREL_ACCESS_MODIFIER DVOETOCHIE CONCEPT_ACCESS_MODIFIER)
            END_POINT)*
    BLOCK_END
    END_POINT
;

class_constructor:
    BINARY_RELATION_RIGHT NREL_CONSTRUCTOR DVOETOCHIE CONSTRUCTOR_NODE
    BLOCK_START
        UNARY_RELATION_RIGHT NODE
        BLOCK_START
        UNARY_RELATION_LEFT CONCEPT_ARGUMENT END_POINT
        (UNARY_RELATION_RIGHT ROLE DVOETOCHIE NODE
            BLOCK_START
                UNARY_RELATION_LEFT CONCEPT_VARIABLE END_POINT
            BLOCK_END END_POINT)*
        BLOCK_END END_POINT


    body END_POINT
    BLOCK_END
    END_POINT
;

method_statement:
    BINARY_RELATION_RIGHT NREL_METHOD DVOETOCHIE CLASS_NODE
    BLOCK_START
        ((UNARY_RELATION_LEFT CONCEPT_METHOD
        | add_keyword
        | BINARY_RELATION_RIGHT NREL_ACCESS_MODIFIER DVOETOCHIE CONCEPT_ACCESS_MODIFIER
        | BINARY_RELATION_RIGHT NREL_RETURN_TYPE DVOETOCHIE CONCEPT type
        ) END_POINT)*
        body?
    BLOCK_END END_POINT
;

called_method:
    NODE
    BLOCK_START
    (((UNARY_RELATION_LEFT CONCEPT_CALLED_METHOD)
    | (BINARY_RELATION_RIGHT NREL_CALLER DVOETOCHIE NODE)
    | (BINARY_RELATION_RIGHT NREL_FUNCTION_PROTOTYPE DVOETOCHIE (operators|CLASS_NODE))
    | (BINARY_RELATION_RIGHT NREL_ARGUMENT DVOETOCHIE NODE
        BLOCK_START
        UNARY_RELATION_LEFT CONCEPT_ARGUMENT END_POINT
        (UNARY_RELATION_RIGHT ROLE DVOETOCHIE (NODE|called_method) END_POINT)*
        BLOCK_END)) END_POINT)*
    BLOCK_END END_POINT
;

add_keyword:
    BINARY_RELATION_RIGHT NREL_KEYWORD DVOETOCHIE CONCEPT keywords END_POINT
;

body:
    BINARY_RELATION_RIGHT NREL_BODY DVOETOCHIE NODE
    BLOCK_START
    UNARY_RELATION_LEFT CODE_BLOCK END_POINT
    runtime_code
    BLOCK_END
;

code: (UNARY_RELATION_LEFT ROLE
    (called_method
    | while_statement
    | if_branching_statement
    | break_rule
    | for_satement))
;

runtime_code:
    (UNARY_RELATION_LEFT ROLE
    ( called_method
    | while_statement
    | if_branching_statement))*
;


cr:code+;

