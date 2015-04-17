//
//  ASLObject.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

extension asl_object_t
{
    subscript(attribute: ASLMessageAttribute)
        -> String?
    {
        get {
            let value = asl_get(self, attribute.rawValue)
            return String.fromCString(value)
        }

        set {
            if let value = newValue {
                asl_set(self, attribute.rawValue, value)
            } else {
                asl_unset(self, attribute.rawValue)
            }
        }
    }
}

public class ASLObject
{
    public enum ASLType: UInt32
    {
        case Undefined  = 0xffffffff    // ASL_TYPE_UNDEF
        case Message    = 0             // ASL_TYPE_MSG
        case Query      = 1             // ASL_TYPE_QUERY
        case List       = 2             // ASL_TYPE_LIST
        case File       = 3             // ASL_TYPE_FILE
        case Store      = 4             // ASL_TYPE_STORE
        case Client     = 5             // ASL_TYPE_CLIENT

        public func create()
            -> asl_object_t
        {
            return asl_new(self.rawValue)
        }
    }

    public let type: ASLType
    public var aslObject: asl_object_t {
        return _aslObject
    }

    private var _aslObject: asl_object_t

    private init(type: ASLType)
    {
        self.type = type
        self._aslObject = type.create()
    }

    deinit {
        asl_free(aslObject)
    }

    subscript(attribute: ASLMessageAttribute)
        -> String?
    {
        get {
            return aslObject[attribute]
        }

        set {
            _aslObject[attribute] = newValue
        }
    }
}

public final class ASLMessageObject: ASLObject
{
    public init()
    {
        super.init(type: .Message)
    }

    public init(priorityLevel: ASLPriorityLevel, message: String)
    {
        super.init(type: .Message)
        self[.Level] = priorityLevel.priorityString
        self[.Message] = message
    }
}

public final class ASLQueryObject: ASLObject
{
    public enum Operation: UInt16
    {
        case EqualTo                = 0x0001    // ASL_QUERY_OP_EQUAL
        case GreaterThan            = 0x0002    // ASL_QUERY_OP_GREATER
        case GreaterThanOrEqualTo   = 0x0003    // ASL_QUERY_OP_GREATER_EQUAL
        case LessThan               = 0x0004    // ASL_QUERY_OP_LESS
        case LessThanOrEqualTo      = 0x0005    // ASL_QUERY_OP_LESS_EQUAL
        case NotEqual               = 0x0006    // ASL_QUERY_OP_NOT_EQUAL
        case KeyExists              = 0x0007    // ASL_QUERY_OP_TRUE
    }

    public struct OperationModifiers: RawOptionSetType, BooleanType
    {
        /** Returns the raw `UInt16` value representing the receiver's bit
        flags. */
        public var rawValue: UInt16 { return self.value }

        /** `true` if the receiver has at least one bit flag set; `false` if
        none are set. */
        public var boolValue: Bool { return self.value != 0 }

        private var value: UInt16

        /**
        Initializes a new `ASLClient.Options` value with the specified
        raw value.

        :param:     rawValue A `UInt16` value containing the raw bit flag
        values to use.
        */
        public init(_ rawValue: UInt16) { self.value = rawValue }

        /**
        Initializes a new `ASLClient.Options` value with the specified
        raw value.

        :param:     rawValue A `UInt32` value containing the raw bit flag
        values to use.
        */
        public init(rawValue: UInt16) { self.value = rawValue }

        /**
        Initializes a new `ASLClient.Options` value with a nil literal,
        which would be the equivalent of the `.None` value.
        */
        public init(nilLiteral: ()) { self.value = 0 }

        /// Returns an `ASLClient.Options` value wherein none of the bit
        /// flags are set.
        public static var allZeros: OperationModifiers          { return self(0) }

        /// Returns an `ASLClient.Options` value wherein none of the bit
        /// flags are set. Equivalent to `allZeros`.
        public static var None: OperationModifiers              { return self(0) }

        public static var CaseInsensitive: OperationModifiers   { return self(UInt16(ASL_QUERY_OP_CASEFOLD)) }

        public static var MatchPrefix: OperationModifiers       { return self(UInt16(ASL_QUERY_OP_PREFIX)) }

        public static var MatchSuffix: OperationModifiers       { return self(UInt16(ASL_QUERY_OP_SUFFIX)) }

        public static var MatchSubstring: OperationModifiers    { return self(UInt16(ASL_QUERY_OP_SUBSTRING)) }

        public static var MatchNumeric: OperationModifiers      { return self(UInt16(ASL_QUERY_OP_NUMERIC)) }

        public static var MatchRegex: OperationModifiers        { return self(UInt16(ASL_QUERY_OP_REGEX)) }
    }

    public init()
    {
        super.init(type: .Query)
    }

    public func setQuery(attribute: ASLMessageAttribute, value: String, operation: ASLQueryObject.Operation, modifiers: OperationModifiers)
    {
    }
}