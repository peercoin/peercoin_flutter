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

@$core.Deprecated('Use emptyRequestDescriptor instead')
const EmptyRequest$json = {
  '1': 'EmptyRequest',
};

/// Descriptor for `EmptyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyRequestDescriptor = $convert.base64Decode(
    'CgxFbXB0eVJlcXVlc3Q=');

@$core.Deprecated('Use blockHeightReplyDescriptor instead')
const BlockHeightReply$json = {
  '1': 'BlockHeightReply',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `BlockHeightReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeightReplyDescriptor = $convert.base64Decode(
    'ChBCbG9ja0hlaWdodFJlcGx5EhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0EiAKCXJwY19lcnJvch'
    'gCIAEoCUgAUghycGNFcnJvcogBAUIMCgpfcnBjX2Vycm9y');

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
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `EstimateFeeReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateFeeReplyDescriptor = $convert.base64Decode(
    'ChBFc3RpbWF0ZUZlZVJlcGx5EhoKCGZlZVBlcktiGAEgASgEUghmZWVQZXJLYhIgCglycGNfZX'
    'Jyb3IYAiABKAlIAFIIcnBjRXJyb3KIAQFCDAoKX3JwY19lcnJvcg==');

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
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `BroadCastTransactionReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadCastTransactionReplyDescriptor = $convert.base64Decode(
    'ChlCcm9hZENhc3RUcmFuc2FjdGlvblJlcGx5EhIKBHR4aWQYASABKAlSBHR4aWQSIAoJcnBjX2'
    'Vycm9yGAIgASgJSABSCHJwY0Vycm9yiAEBQgwKCl9ycGNfZXJyb3I=');

@$core.Deprecated('Use addressRequestDescriptor instead')
const AddressRequest$json = {
  '1': 'AddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'ping', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'ping', '17': true},
  ],
  '8': [
    {'1': '_ping'},
  ],
};

/// Descriptor for `AddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhcKBHBpbmcYAiABKA'
    'lIAFIEcGluZ4gBAUIHCgVfcGluZw==');

@$core.Deprecated('Use addressListRequestDescriptor instead')
const AddressListRequest$json = {
  '1': 'AddressListRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'minimum_height', '3': 2, '4': 1, '5': 5, '9': 0, '10': 'minimumHeight', '17': true},
    {'1': 'ascending', '3': 3, '4': 1, '5': 8, '9': 1, '10': 'ascending', '17': true},
  ],
  '8': [
    {'1': '_minimum_height'},
    {'1': '_ascending'},
  ],
};

/// Descriptor for `AddressListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressListRequestDescriptor = $convert.base64Decode(
    'ChJBZGRyZXNzTGlzdFJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIqCg5taW5pbX'
    'VtX2hlaWdodBgCIAEoBUgAUg1taW5pbXVtSGVpZ2h0iAEBEiEKCWFzY2VuZGluZxgDIAEoCEgB'
    'Uglhc2NlbmRpbmeIAQFCEQoPX21pbmltdW1faGVpZ2h0QgwKCl9hc2NlbmRpbmc=');

@$core.Deprecated('Use addressBalanceReplyDescriptor instead')
const AddressBalanceReply$json = {
  '1': 'AddressBalanceReply',
  '2': [
    {'1': 'confirmed', '3': 1, '4': 1, '5': 4, '10': 'confirmed'},
    {'1': 'unconfirmed', '3': 2, '4': 1, '5': 4, '10': 'unconfirmed'},
    {'1': 'rpc_error', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressBalanceReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressBalanceReplyDescriptor = $convert.base64Decode(
    'ChNBZGRyZXNzQmFsYW5jZVJlcGx5EhwKCWNvbmZpcm1lZBgBIAEoBFIJY29uZmlybWVkEiAKC3'
    'VuY29uZmlybWVkGAIgASgEUgt1bmNvbmZpcm1lZBIgCglycGNfZXJyb3IYAyABKAlIAFIIcnBj'
    'RXJyb3KIAQFCDAoKX3JwY19lcnJvcg==');

@$core.Deprecated('Use addressUtxoListReplyDescriptor instead')
const AddressUtxoListReply$json = {
  '1': 'AddressUtxoListReply',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 9, '10': 'utxos'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressUtxoListReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressUtxoListReplyDescriptor = $convert.base64Decode(
    'ChRBZGRyZXNzVXR4b0xpc3RSZXBseRIUCgV1dHhvcxgBIAMoCVIFdXR4b3MSIAoJcnBjX2Vycm'
    '9yGAIgASgJSABSCHJwY0Vycm9yiAEBQgwKCl9ycGNfZXJyb3I=');

@$core.Deprecated('Use addressUtxoHistoryReplyDescriptor instead')
const AddressUtxoHistoryReply$json = {
  '1': 'AddressUtxoHistoryReply',
  '2': [
    {'1': 'history', '3': 1, '4': 3, '5': 9, '10': 'history'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressUtxoHistoryReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressUtxoHistoryReplyDescriptor = $convert.base64Decode(
    'ChdBZGRyZXNzVXR4b0hpc3RvcnlSZXBseRIYCgdoaXN0b3J5GAEgAygJUgdoaXN0b3J5EiAKCX'
    'JwY19lcnJvchgCIAEoCUgAUghycGNFcnJvcogBAUIMCgpfcnBjX2Vycm9y');

@$core.Deprecated('Use addressHasUtxosReplyDescriptor instead')
const AddressHasUtxosReply$json = {
  '1': 'AddressHasUtxosReply',
  '2': [
    {'1': 'has_utxos', '3': 1, '4': 1, '5': 8, '10': 'hasUtxos'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressHasUtxosReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressHasUtxosReplyDescriptor = $convert.base64Decode(
    'ChRBZGRyZXNzSGFzVXR4b3NSZXBseRIbCgloYXNfdXR4b3MYASABKAhSCGhhc1V0eG9zEiAKCX'
    'JwY19lcnJvchgCIAEoCUgAUghycGNFcnJvcogBAUIMCgpfcnBjX2Vycm9y');

@$core.Deprecated('Use addressNumberOfUtxosReplyDescriptor instead')
const AddressNumberOfUtxosReply$json = {
  '1': 'AddressNumberOfUtxosReply',
  '2': [
    {'1': 'n', '3': 1, '4': 1, '5': 13, '10': 'n'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressNumberOfUtxosReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressNumberOfUtxosReplyDescriptor = $convert.base64Decode(
    'ChlBZGRyZXNzTnVtYmVyT2ZVdHhvc1JlcGx5EgwKAW4YASABKA1SAW4SIAoJcnBjX2Vycm9yGA'
    'IgASgJSABSCHJwY0Vycm9yiAEBQgwKCl9ycGNfZXJyb3I=');

@$core.Deprecated('Use addressIsKnownReplyDescriptor instead')
const AddressIsKnownReply$json = {
  '1': 'AddressIsKnownReply',
  '2': [
    {'1': 'is_known', '3': 1, '4': 1, '5': 8, '10': 'isKnown'},
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressIsKnownReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressIsKnownReplyDescriptor = $convert.base64Decode(
    'ChNBZGRyZXNzSXNLbm93blJlcGx5EhkKCGlzX2tub3duGAEgASgIUgdpc0tub3duEiAKCXJwY1'
    '9lcnJvchgCIAEoCUgAUghycGNFcnJvcogBAUIMCgpfcnBjX2Vycm9y');

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
    {'1': 'rpc_error', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `TxReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txReplyDescriptor = $convert.base64Decode(
    'CgdUeFJlcGx5Eg4KAnR4GAEgASgJUgJ0eBIgCglycGNfZXJyb3IYAiABKAlIAFIIcnBjRXJyb3'
    'KIAQFCDAoKX3JwY19lcnJvcg==');

@$core.Deprecated('Use blockHashStreamRequestDescriptor instead')
const BlockHashStreamRequest$json = {
  '1': 'BlockHashStreamRequest',
};

/// Descriptor for `BlockHashStreamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHashStreamRequestDescriptor = $convert.base64Decode(
    'ChZCbG9ja0hhc2hTdHJlYW1SZXF1ZXN0');

@$core.Deprecated('Use blockHashStreamReplyDescriptor instead')
const BlockHashStreamReply$json = {
  '1': 'BlockHashStreamReply',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'rpc_error', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
    {'1': 'pong', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'pong', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
    {'1': '_pong'},
  ],
};

/// Descriptor for `BlockHashStreamReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHashStreamReplyDescriptor = $convert.base64Decode(
    'ChRCbG9ja0hhc2hTdHJlYW1SZXBseRISCgRoYXNoGAEgASgJUgRoYXNoEhYKBmhlaWdodBgCIA'
    'EoDVIGaGVpZ2h0EiAKCXJwY19lcnJvchgDIAEoCUgAUghycGNFcnJvcogBARIXCgRwb25nGAQg'
    'ASgJSAFSBHBvbmeIAQFCDAoKX3JwY19lcnJvckIHCgVfcG9uZw==');

@$core.Deprecated('Use addressStatusStreamReplyDescriptor instead')
const AddressStatusStreamReply$json = {
  '1': 'AddressStatusStreamReply',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'rpc_error', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
    {'1': 'pong', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'pong', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
    {'1': '_pong'},
  ],
};

/// Descriptor for `AddressStatusStreamReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressStatusStreamReplyDescriptor = $convert.base64Decode(
    'ChhBZGRyZXNzU3RhdHVzU3RyZWFtUmVwbHkSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIWCg'
    'ZzdGF0dXMYAiABKAlSBnN0YXR1cxIgCglycGNfZXJyb3IYAyABKAlIAFIIcnBjRXJyb3KIAQES'
    'FwoEcG9uZxgEIAEoCUgBUgRwb25niAEBQgwKCl9ycGNfZXJyb3JCBwoFX3Bvbmc=');

@$core.Deprecated('Use addressScanStreamReplyDescriptor instead')
const AddressScanStreamReply$json = {
  '1': 'AddressScanStreamReply',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'is_known', '3': 2, '4': 1, '5': 8, '10': 'isKnown'},
    {'1': 'rpc_error', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressScanStreamReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressScanStreamReplyDescriptor = $convert.base64Decode(
    'ChZBZGRyZXNzU2NhblN0cmVhbVJlcGx5EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSGQoIaX'
    'Nfa25vd24YAiABKAhSB2lzS25vd24SIAoJcnBjX2Vycm9yGAMgASgJSABSCHJwY0Vycm9yiAEB'
    'QgwKCl9ycGNfZXJyb3I=');

@$core.Deprecated('Use addressUtxosStreamReplyDescriptor instead')
const AddressUtxosStreamReply$json = {
  '1': 'AddressUtxosStreamReply',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'utxos', '3': 2, '4': 3, '5': 9, '10': 'utxos'},
    {'1': 'rpc_error', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'rpcError', '17': true},
  ],
  '8': [
    {'1': '_rpc_error'},
  ],
};

/// Descriptor for `AddressUtxosStreamReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressUtxosStreamReplyDescriptor = $convert.base64Decode(
    'ChdBZGRyZXNzVXR4b3NTdHJlYW1SZXBseRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBX'
    'V0eG9zGAIgAygJUgV1dHhvcxIgCglycGNfZXJyb3IYAyABKAlIAFIIcnBjRXJyb3KIAQFCDAoK'
    'X3JwY19lcnJvcg==');

