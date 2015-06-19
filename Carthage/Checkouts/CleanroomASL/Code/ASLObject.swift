//
//  ASLObject.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Extends the `asl_object_t` type by adding type-safe subscripting for message
key values.
*/
public extension asl_object_t
{
    /**
    Allows ASL object attributes to be retrieved and set via the subscripting
    notation.

    :param:     key The attribute key.
    
    :returns:   The value associated with `key`, or `nil` if there isn't one.
    */
    public subscript(key: ASLAttributeKey)
        -> String?
    {
        get {
            let value = asl_get(self, key.rawValue)
            if value != nil {
                return String.fromCString(value)
            }
            return nil
        }

        set {
            if let value = newValue {
                asl_set(self, key.rawValue.cStringUsingEncoding(NSUTF8StringEncoding)!, value)
            } else {
                asl_unset(self, key.rawValue.cStringUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
    }

    /**
    Allows the keys of the attributes contained in an ASL message to retrieved 
    using the attribute's index.

    :param:     index The (zero-based) attribute index.
    
    :returns:   The key associated with the attribute at `index`, or `nil` if
                `index` is greater than the number of attributes.
    */
    public subscript(index: UInt32)
        -> String?
    {
        let value = asl_key(self, index)
        if value != nil {
            return String.fromCString(value)
        }
        return nil
    }

    /**
    Counts the number of ASL object attributes contained by the receiver.
    
    :returns:   The number of attributes.
    */
    public func countAttributes()
        -> UInt32
    {
        return UInt32(asl_count(self))
    }
}

/**
Instances of the `ASLObject` class provide type-safe to an underlying
`asl_object_t` of a given `ASL_TYPE`.

Typically, you would interact one of the `ASLObject` subclasses: 
`ASLMessageObject` or `ASLQueryObject`. However, you can also use low-level
ASL functionality using the `asl_object_t` exposed by the `aslObject`
property.

**Note:** `ASLObject` subclass implementations are only provided for
`ASL_TYPE_MSG` (the `ASLMessageObject` class) and `ASL_TYPE_QUERY` 
(the `ASLQueryObject` class).
*/
public class ASLObject
{
    /**
    Represents the various `ASL_TYPE` values.
    */
    public enum ASLType: UInt32
    {
        /** Equivalent to `ASL_TYPE_UNDEF`. */
        case Undefined  = 0xffffffff

        /** Equivalent to `ASL_TYPE_MSG`. */
        case Message    = 0

        /** Equivalent to `ASL_TYPE_QUERY`. */
        case Query      = 1

        /** Equivalent to `ASL_TYPE_LIST`. */
        case List       = 2

        /** Equivalent to `ASL_TYPE_FILE`. */
        case File       = 3

        /** Equivalent to `ASL_TYPE_STORE`. */
        case Store      = 4

        /** Equivalent to `ASL_TYPE_CLIENT`. */
        case Client     = 5

        /**
        Creates a new `asl_object_t` for the `ASL_TYPE` represented by
        the receiver.
        
        :returns:   The new `asl_object_t`.
        */
        public func create()
            -> asl_object_t
        {
            return asl_new(self.rawValue)
        }
    }

    /** Indicates the `ASLType` represented by the receiver. */
    public let type: ASLType

    /** Returns the underlying `asl_object_t` represented by the receiver. 
    You can use this for direct, low-level access to the Apple System Log
    API. */
    public var aslObject: asl_object_t {
        return _aslObject
    }

    private var _aslObject: asl_object_t

    /**
    Initializes a new `ASLObject` instance to represent the given `ASLType`.
    
    :param:     type The `ASLType` that determines the
    */
    private init(type: ASLType)
    {
        self.type = type
        self._aslObject = type.create()
    }

    deinit {
        asl_free(_aslObject)
    }

    /**
    Allows ASL object attributes to be retrieved and set via the subscripting
    notation.
    
    :param:     key The attribute key.
    
    :returns:   The value associated with `key`, or `nil` if there isn't one.
    */
    public subscript(key: ASLAttributeKey)
        -> String?
    {
        get { return _aslObject[key] }

        set { _aslObject[key] = newValue }
    }

    /**
    Allows the keys of ASL object attributes to retrieved using the attribute's
    index.

    :param:     index The (zero-based) attribute index.
    
    :returns:   The key associated with the attribute at `index`, or `nil` if
                `index` is greater than the number of attributes.
    */
    public subscript(index: UInt32)
        -> String?
    {
        return _aslObject[index]
    }

    /**
    Counts the number of ASL object attributes contained by the receiver.
    
    :returns:   The number of attributes.
    */
    public func countAttributes()
        -> UInt32
    {
        return _aslObject.countAttributes()
    }
}

/**
Represents an ASL message object.

Message objects represent an `asl_object_t` having a type of `ASL_TYPE_MSG`.
*/
public final class ASLMessageObject: ASLObject
{
    /**
    Initializes an empty `ASLMessageObject`.
    */
    public init()
    {
        super.init(type: .Message)
    }

    /**
    Initializes an `ASLMessageObject` having the specified priority level
    and message.
    
    :param:     priorityLevel The `ASLPriorityLevel` to use for the message
                being constructed.
    
    :param:     message The content of the message itself.
    */
    public init(priorityLevel: ASLPriorityLevel, message: String)
    {
        super.init(type: .Message)
        self[.Level] = priorityLevel.priorityString
        self[.Message] = message
    }
}

/**
Represents an ASL query object.

Message objects represent an `asl_object_t` having a type of `ASL_TYPE_QUERY`.
*/
public final class ASLQueryObject: ASLObject
{
    /**
    Represents an ASL query operation. Query operations are used for comparing
    values when searches are being performed.
    */
    public enum Operation: UInt32
    {
        /** Specifies that the query should match records whose value for the
        given key is equal to the one provided. Equivalent to 
        `ASL_QUERY_OP_EQUAL`. */
        case EqualTo                = 0x0001

        /** Specifies that the query should match records whose value for the
        given key is greater than the one provided. Equivalent to
        `ASL_QUERY_OP_GREATER`. */
        case GreaterThan            = 0x0002

        /** Specifies that the query should match records whose value for the
        given key is greater than or equal to the one provided. Equivalent to
        `ASL_QUERY_OP_GREATER_EQUAL`. */
        case GreaterThanOrEqualTo   = 0x0003

        /** Specifies that the query should match records whose value for the
        given key is less than the one provided. Equivalent to
        `ASL_QUERY_OP_LESS`. */
        case LessThan               = 0x0004

        /** Specifies that the query should match records whose value for the
        given key is less than or equal to the one provided. Equivalent to
        `ASL_QUERY_OP_LESS_EQUAL`. */
        case LessThanOrEqualTo      = 0x0005

        /** Specifies that the query should match records whose value for the
        given key is not equal to the one provided. Equivalent to
        `ASL_QUERY_OP_NOT_EQUAL`. */
        case NotEqual               = 0x0006

        /** Specifies that the query should match records having values for the
        given key. Equivalent to `ASL_QUERY_OP_TRUE`. */
        case KeyExists              = 0x0007
    }

    /**
    Represents modifiers used to change the behavior of a query operation.
    These are bit-flag values that can be combined and otherwise manipulated 
    with bitwise operators.
    */
    public struct OperationModifiers: OptionSetType
    {
        /** The raw `UInt32` value representing the receiver's bit flags. */
        public let rawValue: UInt32

        /**
        Initializes a new `ASLQueryObject.OperationModifiers` value with the
        specified raw value.

        :param:     rawValue A `UInt32` value containing the raw bit flag
                    values to use.
        */
        public init(rawValue: UInt32) { self.rawValue = rawValue }

        /** An `ASLQueryObject.OperationModifiers` value wherein none of the
        bit flags are set. */
        public static let None = OperationModifiers(rawValue: 0)

        /** Specifies that the query operation should perform case-insensitive
        matching. Equivalent to `ASL_QUERY_OP_CASEFOLD`. */
        public static let CaseInsensitive = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_CASEFOLD))

        /** Specifies that the query operation will attempt to match the search
        value against the beginning of each record's value for the given key.
        Equivalent to `ASL_QUERY_OP_PREFIX`. */
        public static let MatchPrefix = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_PREFIX))

        /** Specifies that the query operation will attempt to match the search
        value against the end of each record's value for the given key. 
        Equivalent to `ASL_QUERY_OP_SUFFIX`. */
        public static let MatchSuffix = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_SUFFIX))

        /** Specifies that the query operation will attempt to find the search
        value within each record's value for the given key. Equivalent to
        `ASL_QUERY_OP_SUBSTRING`. */
        public static let MatchSubstring = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_SUBSTRING))

        /** Specifies that the query operation will perform numeric instead of
        text comparison. The query operation will interpret the search value
        and each record value as integers before performing the comparison
        operation. Equivalent to `ASL_QUERY_OP_NUMERIC`. */
        public static let MatchNumeric = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_NUMERIC))

        /** Specifies that the query operation will perform regular expression
        matching. The query operation will interpret the search value as a
        regular expression that will be applied against the each record's
        value for the given key. Equivalent to `ASL_QUERY_OP_REGEX`. */
        public static let MatchRegex = OperationModifiers(rawValue: UInt32(ASL_QUERY_OP_REGEX))
    }

    /**
    The function signature implemented by ASL search query result handlers.

    When an `ASLClient`'s `search()` function is called, this callback is
    provided as a parameter.

    For each record in the query's result set, the callback function is
    executed once and passed a `ResultRecord` value. After all results
    have been reported, the callback is executed one final time, with `nil`
    passed instead of an actual record.

    The callback implementation should return `true` as long as additional
    `ResultRecord`s are desired.
    
    The callback can short-circuit delivery of additional results by returning
    `false` at any time. Once the callback returns `false`, it will not be 
    called again for the givens query.
    */
    public typealias ResultCallback = (ResultRecord?) -> Bool

    /**
    A query result record. For each log message matched by an ASL search
    query, a `ResultRecord` representing that message is passed to the
    `ResultCallback` responsible for handling the query results.
    */
    public struct ResultRecord
    {
        /** The `ASLClient` that executed the search query. */
        public weak var client: ASLClient?

        /** The `ASLQueryObject` whose query results contain the record. */
        public weak var query: ASLQueryObject?

        /** The priority of the log message. */
        public let priority: ASLPriorityLevel

        /** The string content of the log message. */
        public let message: String

        /** The system time when the log message was recorded. */
        public let timestamp: NSDate
    }

    /**
    Initializes an empty `ASLQueryObject`.
    */
    public init()
    {
        super.init(type: .Query)
    }

    /**
    Sets a query operation for the given key and string-based value.

    When a search query is executed, the result set will be constrained
    according to the query key(s) that have been set on the receiver.
    
    :param:     key An `ASLAttributeKey` specifying the key whose value will
                be queried.
    
    :param:     value The string value to find.
    
    :param:     operation Specifies the query `Operation` to be performed. This
                governs how values will be matched by the search.
    
    :param:     modifiers The `OperationModifiers` bit flags that modify the
                behavior of the search operation.
    */
    public func setQueryKey(key: ASLAttributeKey, value: String?, operation: Operation, modifiers: OperationModifiers)
    {
        asl_set_query(aslObject, key.rawValue.cStringUsingEncoding(NSUTF8StringEncoding)!, value?.cStringUsingEncoding(NSUTF8StringEncoding)! ?? nil, operation.rawValue | modifiers.rawValue)
    }

    /**
    Sets a query operation for the given key and string-based value.

    When a search query is executed, the result set will be constrained
    according to the query key(s) that have been set on the receiver.
    
    :param:     key An `ASLAttributeKey` specifying the key whose value will
                be queried.
    
    :param:     value The integer value to find.
    
    :param:     operation Specifies the query `Operation` to be performed. This
                governs how values will be matched by the search.
    
    :param:     modifiers The `OperationModifiers` bit flags that modify the
                behavior of the search operation. Note that using this method
                variant automatically causes the `.MatchNumeric` bit flag to
                be set.
    */
    public func setQueryKey(key: ASLAttributeKey, value: Int, operation: Operation, modifiers: OperationModifiers)
    {
        asl_set_query(aslObject, key.rawValue.cStringUsingEncoding(NSUTF8StringEncoding)!, String(value).cStringUsingEncoding(NSUTF8StringEncoding)!, operation.rawValue | modifiers.rawValue | OperationModifiers.MatchNumeric.rawValue)
    }
}