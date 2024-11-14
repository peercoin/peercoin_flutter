//
//  Generated code. Do not modify.
//  source: marisma.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use blockHeightRequestDescriptor instead')
const BlockHeightRequest$json = {
  '1': 'BlockHeightRequest',
};

/// Descriptor for `BlockHeightRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeightRequestDescriptor = $convert.base64Decode(
    'ChJCbG9ja0hlaWdodFJlcXVlc3Q=');

@$core.Deprecated('Use blockHeightReplyDescriptor instead')
const BlockHeightReply$json = {
  '1': 'BlockHeightReply',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `BlockHeightReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeightReplyDescriptor = $convert.base64Decode(
    'ChBCbG9ja0hlaWdodFJlcGx5EhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0');

@$core.Deprecated('Use estimateFeeRequestDescriptor instead')
const EstimateFeeRequest$json = {
  '1': 'EstimateFeeRequest',
  '2': [
    {'1': 'blockTarget', '3': 1, '4': 1, '5': 13, '10': 'blockTarget'},
  ],
};

/// Descriptor for `EstimateFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateFeeRequestDescriptor = $convert.base64Decode(
    'ChJFc3RpbWF0ZUZlZVJlcXVlc3QSIAoLYmxvY2tUYXJnZXQYASABKA1SC2Jsb2NrVGFyZ2V0');

@$core.Deprecated('Use estimateFeeReplyDescriptor instead')
const EstimateFeeReply$json = {
  '1': 'EstimateFeeReply',
  '2': [
    {'1': 'feePerKb', '3': 1, '4': 1, '5': 4, '10': 'feePerKb'},
  ],
};

/// Descriptor for `EstimateFeeReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateFeeReplyDescriptor = $convert.base64Decode(
    'ChBFc3RpbWF0ZUZlZVJlcGx5EhoKCGZlZVBlcktiGAEgASgEUghmZWVQZXJLYg==');

@$core.Deprecated('Use broadCastTransactionRequestDescriptor instead')
const BroadCastTransactionRequest$json = {
  '1': 'BroadCastTransactionRequest',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `BroadCastTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadCastTransactionRequestDescriptor = $convert.base64Decode(
    'ChtCcm9hZENhc3RUcmFuc2FjdGlvblJlcXVlc3QSEAoDaGV4GAEgASgJUgNoZXg=');

@$core.Deprecated('Use broadCastTransactionReplyDescriptor instead')
const BroadCastTransactionReply$json = {
  '1': 'BroadCastTransactionReply',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'rpcError', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpcError'},
  ],
};

/// Descriptor for `BroadCastTransactionReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadCastTransactionReplyDescriptor = $convert.base64Decode(
    'ChlCcm9hZENhc3RUcmFuc2FjdGlvblJlcGx5EhIKBHR4aWQYASABKAlSBHR4aWQSHwoIcnBjRX'
    'Jyb3IYAiABKAlIAFIIcnBjRXJyb3KIAQFCCwoJX3JwY0Vycm9y');

@$core.Deprecated('Use addressRequestDescriptor instead')
const AddressRequest$json = {
  '1': 'AddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `AddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use addressListRequestDescriptor instead')
const AddressListRequest$json = {
  '1': 'AddressListRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'ascending', '3': 2, '4': 1, '5': 8, '10': 'ascending'},
  ],
};

/// Descriptor for `AddressListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressListRequestDescriptor = $convert.base64Decode(
    'ChJBZGRyZXNzTGlzdFJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIcCglhc2Nlbm'
    'RpbmcYAiABKAhSCWFzY2VuZGluZw==');

@$core.Deprecated('Use addressBalanceReplyDescriptor instead')
const AddressBalanceReply$json = {
  '1': 'AddressBalanceReply',
  '2': [
    {'1': 'balance', '3': 1, '4': 1, '5': 4, '10': 'balance'},
  ],
};

/// Descriptor for `AddressBalanceReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressBalanceReplyDescriptor = $convert.base64Decode(
    'ChNBZGRyZXNzQmFsYW5jZVJlcGx5EhgKB2JhbGFuY2UYASABKARSB2JhbGFuY2U=');

@$core.Deprecated('Use addressUtxoListReplyDescriptor instead')
const AddressUtxoListReply$json = {
  '1': 'AddressUtxoListReply',
  '2': [
    {'1': 'utxos', '3': 1, '4': 1, '5': 9, '10': 'utxos'},
  ],
};

/// Descriptor for `AddressUtxoListReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressUtxoListReplyDescriptor = $convert.base64Decode(
    'ChRBZGRyZXNzVXR4b0xpc3RSZXBseRIUCgV1dHhvcxgBIAEoCVIFdXR4b3M=');

@$core.Deprecated('Use addressHistoryReplyDescriptor instead')
const AddressHistoryReply$json = {
  '1': 'AddressHistoryReply',
  '2': [
    {'1': 'history', '3': 1, '4': 3, '5': 9, '10': 'history'},
  ],
};

/// Descriptor for `AddressHistoryReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressHistoryReplyDescriptor = $convert.base64Decode(
    'ChNBZGRyZXNzSGlzdG9yeVJlcGx5EhgKB2hpc3RvcnkYASADKAlSB2hpc3Rvcnk=');

@$core.Deprecated('Use addressHasUtxosReplyDescriptor instead')
const AddressHasUtxosReply$json = {
  '1': 'AddressHasUtxosReply',
  '2': [
    {'1': 'has_utxos', '3': 1, '4': 1, '5': 8, '10': 'hasUtxos'},
  ],
};

/// Descriptor for `AddressHasUtxosReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressHasUtxosReplyDescriptor = $convert.base64Decode(
    'ChRBZGRyZXNzSGFzVXR4b3NSZXBseRIbCgloYXNfdXR4b3MYASABKAhSCGhhc1V0eG9z');

@$core.Deprecated('Use addressNumberOfUtxosReplyDescriptor instead')
const AddressNumberOfUtxosReply$json = {
  '1': 'AddressNumberOfUtxosReply',
  '2': [
    {'1': 'n', '3': 1, '4': 1, '5': 13, '10': 'n'},
  ],
};

/// Descriptor for `AddressNumberOfUtxosReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressNumberOfUtxosReplyDescriptor = $convert.base64Decode(
    'ChlBZGRyZXNzTnVtYmVyT2ZVdHhvc1JlcGx5EgwKAW4YASABKA1SAW4=');

@$core.Deprecated('Use addressIsKnownReplyDescriptor instead')
const AddressIsKnownReply$json = {
  '1': 'AddressIsKnownReply',
  '2': [
    {'1': 'is_known', '3': 1, '4': 1, '5': 8, '10': 'isKnown'},
  ],
};

/// Descriptor for `AddressIsKnownReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressIsKnownReplyDescriptor = $convert.base64Decode(
    'ChNBZGRyZXNzSXNLbm93blJlcGx5EhkKCGlzX2tub3duGAEgASgIUgdpc0tub3du');

@$core.Deprecated('Use txRequestDescriptor instead')
const TxRequest$json = {
  '1': 'TxRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TxRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txRequestDescriptor = $convert.base64Decode(
    'CglUeFJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use txReplyDescriptor instead')
const TxReply$json = {
  '1': 'TxReply',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 9, '10': 'tx'},
  ],
};

/// Descriptor for `TxReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txReplyDescriptor = $convert.base64Decode(
    'CgdUeFJlcGx5Eg4KAnR4GAEgASgJUgJ0eA==');

@$core.Deprecated('Use testStreamRequestDescriptor instead')
const TestStreamRequest$json = {
  '1': 'TestStreamRequest',
};

/// Descriptor for `TestStreamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testStreamRequestDescriptor = $convert.base64Decode(
    'ChFUZXN0U3RyZWFtUmVxdWVzdA==');

@$core.Deprecated('Use testStreamReplyDescriptor instead')
const TestStreamReply$json = {
  '1': 'TestStreamReply',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `TestStreamReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testStreamReplyDescriptor = $convert.base64Decode(
    'Cg9UZXN0U3RyZWFtUmVwbHkSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

