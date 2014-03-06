#### sparse.Relation
class sparse.Relation extends Object
  constructor:(@parent,@key)->
  _ensureParentAndKey: (parent, key)->
    throw 'Internal Error. Relation retrieved from two different Objects.' if (@parent ?= parent) != parent
    throw 'Internal Error. Relation retrieved from two different keys.' if (@key ?= key) != key
  add: (objects)->
    objects = [objects] if !_.isArray objects
    # change = new Parse.Op.Relation(objects, []);
    # this.parent.set(this.key, change);
    # this.targetClassName = change._targetClassName;