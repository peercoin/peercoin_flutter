//
//  Generated code. Do not modify.
//  source: marisma.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class EmptyRequest extends $pb.GeneratedMessage {
  factory EmptyRequest() => create();
  EmptyRequest._() : super();
  factory EmptyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EmptyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmptyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EmptyRequest clone() => EmptyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EmptyRequest copyWith(void Function(EmptyRequest) updates) => super.copyWith((message) => updates(message as EmptyRequest)) as EmptyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmptyRequest create() => EmptyRequest._();
  EmptyRequest createEmptyInstance() => create();
  static $pb.PbList<EmptyRequest> createRepeated() => $pb.PbList<EmptyRequest>();
  @$core.pragma('dart2js:noInline')
  static EmptyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmptyRequest>(create);
  static EmptyRequest? _defaultInstance;
}

class BlockHeightReply extends $pb.GeneratedMessage {
  factory BlockHeightReply({
    $core.int? height,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  BlockHeightReply._() : super();
  factory BlockHeightReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockHeightReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHeightReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockHeightReply clone() => BlockHeightReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockHeightReply copyWith(void Function(BlockHeightReply) updates) => super.copyWith((message) => updates(message as BlockHeightReply)) as BlockHeightReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockHeightReply create() => BlockHeightReply._();
  BlockHeightReply createEmptyInstance() => create();
  static $pb.PbList<BlockHeightReply> createRepeated() => $pb.PbList<BlockHeightReply>();
  @$core.pragma('dart2js:noInline')
  static BlockHeightReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHeightReply>(create);
  static BlockHeightReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class EstimateFeeRequest extends $pb.GeneratedMessage {
  factory EstimateFeeRequest({
    $core.int? blockTarget,
  }) {
    final $result = create();
    if (blockTarget != null) {
      $result.blockTarget = blockTarget;
    }
    return $result;
  }
  EstimateFeeRequest._() : super();
  factory EstimateFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blockTarget', $pb.PbFieldType.OU3, protoName: 'blockTarget')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateFeeRequest clone() => EstimateFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateFeeRequest copyWith(void Function(EstimateFeeRequest) updates) => super.copyWith((message) => updates(message as EstimateFeeRequest)) as EstimateFeeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateFeeRequest create() => EstimateFeeRequest._();
  EstimateFeeRequest createEmptyInstance() => create();
  static $pb.PbList<EstimateFeeRequest> createRepeated() => $pb.PbList<EstimateFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeRequest>(create);
  static EstimateFeeRequest? _defaultInstance;

  /// Return the estimated transaction fee per kilobyte for a transaction to be confirmed within a certain number of blocks.
  @$pb.TagNumber(1)
  $core.int get blockTarget => $_getIZ(0);
  @$pb.TagNumber(1)
  set blockTarget($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockTarget() => clearField(1);
}

class EstimateFeeReply extends $pb.GeneratedMessage {
  factory EstimateFeeReply({
    $fixnum.Int64? feePerKb,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (feePerKb != null) {
      $result.feePerKb = feePerKb;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  EstimateFeeReply._() : super();
  factory EstimateFeeReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateFeeReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'feePerKb', $pb.PbFieldType.OU6, protoName: 'feePerKb', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateFeeReply clone() => EstimateFeeReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateFeeReply copyWith(void Function(EstimateFeeReply) updates) => super.copyWith((message) => updates(message as EstimateFeeReply)) as EstimateFeeReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateFeeReply create() => EstimateFeeReply._();
  EstimateFeeReply createEmptyInstance() => create();
  static $pb.PbList<EstimateFeeReply> createRepeated() => $pb.PbList<EstimateFeeReply>();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeReply>(create);
  static EstimateFeeReply? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feePerKb => $_getI64(0);
  @$pb.TagNumber(1)
  set feePerKb($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeePerKb() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeePerKb() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class BroadCastTransactionRequest extends $pb.GeneratedMessage {
  factory BroadCastTransactionRequest({
    $core.String? hex,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  BroadCastTransactionRequest._() : super();
  factory BroadCastTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadCastTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadCastTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadCastTransactionRequest clone() => BroadCastTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadCastTransactionRequest copyWith(void Function(BroadCastTransactionRequest) updates) => super.copyWith((message) => updates(message as BroadCastTransactionRequest)) as BroadCastTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadCastTransactionRequest create() => BroadCastTransactionRequest._();
  BroadCastTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<BroadCastTransactionRequest> createRepeated() => $pb.PbList<BroadCastTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static BroadCastTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadCastTransactionRequest>(create);
  static BroadCastTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);
}

class BroadCastTransactionReply extends $pb.GeneratedMessage {
  factory BroadCastTransactionReply({
    $core.String? txid,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  BroadCastTransactionReply._() : super();
  factory BroadCastTransactionReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadCastTransactionReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadCastTransactionReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadCastTransactionReply clone() => BroadCastTransactionReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadCastTransactionReply copyWith(void Function(BroadCastTransactionReply) updates) => super.copyWith((message) => updates(message as BroadCastTransactionReply)) as BroadCastTransactionReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadCastTransactionReply create() => BroadCastTransactionReply._();
  BroadCastTransactionReply createEmptyInstance() => create();
  static $pb.PbList<BroadCastTransactionReply> createRepeated() => $pb.PbList<BroadCastTransactionReply>();
  @$core.pragma('dart2js:noInline')
  static BroadCastTransactionReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadCastTransactionReply>(create);
  static BroadCastTransactionReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class AddressRequest extends $pb.GeneratedMessage {
  factory AddressRequest({
    $core.String? address,
    $core.String? ping,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (ping != null) {
      $result.ping = ping;
    }
    return $result;
  }
  AddressRequest._() : super();
  factory AddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'ping')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressRequest clone() => AddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressRequest copyWith(void Function(AddressRequest) updates) => super.copyWith((message) => updates(message as AddressRequest)) as AddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressRequest create() => AddressRequest._();
  AddressRequest createEmptyInstance() => create();
  static $pb.PbList<AddressRequest> createRepeated() => $pb.PbList<AddressRequest>();
  @$core.pragma('dart2js:noInline')
  static AddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressRequest>(create);
  static AddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get ping => $_getSZ(1);
  @$pb.TagNumber(2)
  set ping($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPing() => $_has(1);
  @$pb.TagNumber(2)
  void clearPing() => clearField(2);
}

class AddressListRequest extends $pb.GeneratedMessage {
  factory AddressListRequest({
    $core.String? address,
    $core.int? minimumHeight,
    $core.bool? ascending,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (minimumHeight != null) {
      $result.minimumHeight = minimumHeight;
    }
    if (ascending != null) {
      $result.ascending = ascending;
    }
    return $result;
  }
  AddressListRequest._() : super();
  factory AddressListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'minimumHeight', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'ascending')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressListRequest clone() => AddressListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressListRequest copyWith(void Function(AddressListRequest) updates) => super.copyWith((message) => updates(message as AddressListRequest)) as AddressListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressListRequest create() => AddressListRequest._();
  AddressListRequest createEmptyInstance() => create();
  static $pb.PbList<AddressListRequest> createRepeated() => $pb.PbList<AddressListRequest>();
  @$core.pragma('dart2js:noInline')
  static AddressListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressListRequest>(create);
  static AddressListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get minimumHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set minimumHeight($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMinimumHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinimumHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get ascending => $_getBF(2);
  @$pb.TagNumber(3)
  set ascending($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAscending() => $_has(2);
  @$pb.TagNumber(3)
  void clearAscending() => clearField(3);
}

class AddressBalanceReply extends $pb.GeneratedMessage {
  factory AddressBalanceReply({
    $fixnum.Int64? confirmed,
    $fixnum.Int64? unconfirmed,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (unconfirmed != null) {
      $result.unconfirmed = unconfirmed;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressBalanceReply._() : super();
  factory AddressBalanceReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressBalanceReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressBalanceReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'confirmed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'unconfirmed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressBalanceReply clone() => AddressBalanceReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressBalanceReply copyWith(void Function(AddressBalanceReply) updates) => super.copyWith((message) => updates(message as AddressBalanceReply)) as AddressBalanceReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressBalanceReply create() => AddressBalanceReply._();
  AddressBalanceReply createEmptyInstance() => create();
  static $pb.PbList<AddressBalanceReply> createRepeated() => $pb.PbList<AddressBalanceReply>();
  @$core.pragma('dart2js:noInline')
  static AddressBalanceReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressBalanceReply>(create);
  static AddressBalanceReply? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confirmed => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmed($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmed() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmed() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get unconfirmed => $_getI64(1);
  @$pb.TagNumber(2)
  set unconfirmed($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnconfirmed() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmed() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rpcError => $_getSZ(2);
  @$pb.TagNumber(3)
  set rpcError($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRpcError() => $_has(2);
  @$pb.TagNumber(3)
  void clearRpcError() => clearField(3);
}

class AddressUtxoListReply extends $pb.GeneratedMessage {
  factory AddressUtxoListReply({
    $core.Iterable<$core.String>? utxos,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (utxos != null) {
      $result.utxos.addAll(utxos);
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressUtxoListReply._() : super();
  factory AddressUtxoListReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressUtxoListReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressUtxoListReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'utxos')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressUtxoListReply clone() => AddressUtxoListReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressUtxoListReply copyWith(void Function(AddressUtxoListReply) updates) => super.copyWith((message) => updates(message as AddressUtxoListReply)) as AddressUtxoListReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressUtxoListReply create() => AddressUtxoListReply._();
  AddressUtxoListReply createEmptyInstance() => create();
  static $pb.PbList<AddressUtxoListReply> createRepeated() => $pb.PbList<AddressUtxoListReply>();
  @$core.pragma('dart2js:noInline')
  static AddressUtxoListReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressUtxoListReply>(create);
  static AddressUtxoListReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get utxos => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class AddressUtxoHistoryReply extends $pb.GeneratedMessage {
  factory AddressUtxoHistoryReply({
    $core.Iterable<$core.String>? history,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (history != null) {
      $result.history.addAll(history);
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressUtxoHistoryReply._() : super();
  factory AddressUtxoHistoryReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressUtxoHistoryReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressUtxoHistoryReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'history')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressUtxoHistoryReply clone() => AddressUtxoHistoryReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressUtxoHistoryReply copyWith(void Function(AddressUtxoHistoryReply) updates) => super.copyWith((message) => updates(message as AddressUtxoHistoryReply)) as AddressUtxoHistoryReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressUtxoHistoryReply create() => AddressUtxoHistoryReply._();
  AddressUtxoHistoryReply createEmptyInstance() => create();
  static $pb.PbList<AddressUtxoHistoryReply> createRepeated() => $pb.PbList<AddressUtxoHistoryReply>();
  @$core.pragma('dart2js:noInline')
  static AddressUtxoHistoryReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressUtxoHistoryReply>(create);
  static AddressUtxoHistoryReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get history => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class AddressHasUtxosReply extends $pb.GeneratedMessage {
  factory AddressHasUtxosReply({
    $core.bool? hasUtxos,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (hasUtxos != null) {
      $result.hasUtxos = hasUtxos;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressHasUtxosReply._() : super();
  factory AddressHasUtxosReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressHasUtxosReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressHasUtxosReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasUtxos')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressHasUtxosReply clone() => AddressHasUtxosReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressHasUtxosReply copyWith(void Function(AddressHasUtxosReply) updates) => super.copyWith((message) => updates(message as AddressHasUtxosReply)) as AddressHasUtxosReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressHasUtxosReply create() => AddressHasUtxosReply._();
  AddressHasUtxosReply createEmptyInstance() => create();
  static $pb.PbList<AddressHasUtxosReply> createRepeated() => $pb.PbList<AddressHasUtxosReply>();
  @$core.pragma('dart2js:noInline')
  static AddressHasUtxosReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressHasUtxosReply>(create);
  static AddressHasUtxosReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasUtxos => $_getBF(0);
  @$pb.TagNumber(1)
  set hasUtxos($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasUtxos() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasUtxos() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class AddressNumberOfUtxosReply extends $pb.GeneratedMessage {
  factory AddressNumberOfUtxosReply({
    $core.int? n,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (n != null) {
      $result.n = n;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressNumberOfUtxosReply._() : super();
  factory AddressNumberOfUtxosReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressNumberOfUtxosReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressNumberOfUtxosReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'n', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressNumberOfUtxosReply clone() => AddressNumberOfUtxosReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressNumberOfUtxosReply copyWith(void Function(AddressNumberOfUtxosReply) updates) => super.copyWith((message) => updates(message as AddressNumberOfUtxosReply)) as AddressNumberOfUtxosReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressNumberOfUtxosReply create() => AddressNumberOfUtxosReply._();
  AddressNumberOfUtxosReply createEmptyInstance() => create();
  static $pb.PbList<AddressNumberOfUtxosReply> createRepeated() => $pb.PbList<AddressNumberOfUtxosReply>();
  @$core.pragma('dart2js:noInline')
  static AddressNumberOfUtxosReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressNumberOfUtxosReply>(create);
  static AddressNumberOfUtxosReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get n => $_getIZ(0);
  @$pb.TagNumber(1)
  set n($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasN() => $_has(0);
  @$pb.TagNumber(1)
  void clearN() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class AddressIsKnownReply extends $pb.GeneratedMessage {
  factory AddressIsKnownReply({
    $core.bool? isKnown,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (isKnown != null) {
      $result.isKnown = isKnown;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressIsKnownReply._() : super();
  factory AddressIsKnownReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressIsKnownReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressIsKnownReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isKnown')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressIsKnownReply clone() => AddressIsKnownReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressIsKnownReply copyWith(void Function(AddressIsKnownReply) updates) => super.copyWith((message) => updates(message as AddressIsKnownReply)) as AddressIsKnownReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressIsKnownReply create() => AddressIsKnownReply._();
  AddressIsKnownReply createEmptyInstance() => create();
  static $pb.PbList<AddressIsKnownReply> createRepeated() => $pb.PbList<AddressIsKnownReply>();
  @$core.pragma('dart2js:noInline')
  static AddressIsKnownReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressIsKnownReply>(create);
  static AddressIsKnownReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isKnown => $_getBF(0);
  @$pb.TagNumber(1)
  set isKnown($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsKnown() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsKnown() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class TxRequest extends $pb.GeneratedMessage {
  factory TxRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TxRequest._() : super();
  factory TxRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TxRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxRequest clone() => TxRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxRequest copyWith(void Function(TxRequest) updates) => super.copyWith((message) => updates(message as TxRequest)) as TxRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TxRequest create() => TxRequest._();
  TxRequest createEmptyInstance() => create();
  static $pb.PbList<TxRequest> createRepeated() => $pb.PbList<TxRequest>();
  @$core.pragma('dart2js:noInline')
  static TxRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxRequest>(create);
  static TxRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class TxReply extends $pb.GeneratedMessage {
  factory TxReply({
    $core.String? tx,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  TxReply._() : super();
  factory TxReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TxReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tx')
    ..aOS(2, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxReply clone() => TxReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxReply copyWith(void Function(TxReply) updates) => super.copyWith((message) => updates(message as TxReply)) as TxReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TxReply create() => TxReply._();
  TxReply createEmptyInstance() => create();
  static $pb.PbList<TxReply> createRepeated() => $pb.PbList<TxReply>();
  @$core.pragma('dart2js:noInline')
  static TxReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxReply>(create);
  static TxReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tx => $_getSZ(0);
  @$pb.TagNumber(1)
  set tx($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get rpcError => $_getSZ(1);
  @$pb.TagNumber(2)
  set rpcError($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRpcError() => $_has(1);
  @$pb.TagNumber(2)
  void clearRpcError() => clearField(2);
}

class BlockHashStreamRequest extends $pb.GeneratedMessage {
  factory BlockHashStreamRequest() => create();
  BlockHashStreamRequest._() : super();
  factory BlockHashStreamRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockHashStreamRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHashStreamRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockHashStreamRequest clone() => BlockHashStreamRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockHashStreamRequest copyWith(void Function(BlockHashStreamRequest) updates) => super.copyWith((message) => updates(message as BlockHashStreamRequest)) as BlockHashStreamRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockHashStreamRequest create() => BlockHashStreamRequest._();
  BlockHashStreamRequest createEmptyInstance() => create();
  static $pb.PbList<BlockHashStreamRequest> createRepeated() => $pb.PbList<BlockHashStreamRequest>();
  @$core.pragma('dart2js:noInline')
  static BlockHashStreamRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHashStreamRequest>(create);
  static BlockHashStreamRequest? _defaultInstance;
}

class BlockHashStreamReply extends $pb.GeneratedMessage {
  factory BlockHashStreamReply({
    $core.String? hash,
    $core.int? height,
    $core.String? rpcError,
    $core.String? pong,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    if (height != null) {
      $result.height = height;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    if (pong != null) {
      $result.pong = pong;
    }
    return $result;
  }
  BlockHashStreamReply._() : super();
  factory BlockHashStreamReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockHashStreamReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHashStreamReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'rpcError')
    ..aOS(4, _omitFieldNames ? '' : 'pong')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockHashStreamReply clone() => BlockHashStreamReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockHashStreamReply copyWith(void Function(BlockHashStreamReply) updates) => super.copyWith((message) => updates(message as BlockHashStreamReply)) as BlockHashStreamReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockHashStreamReply create() => BlockHashStreamReply._();
  BlockHashStreamReply createEmptyInstance() => create();
  static $pb.PbList<BlockHashStreamReply> createRepeated() => $pb.PbList<BlockHashStreamReply>();
  @$core.pragma('dart2js:noInline')
  static BlockHashStreamReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHashStreamReply>(create);
  static BlockHashStreamReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rpcError => $_getSZ(2);
  @$pb.TagNumber(3)
  set rpcError($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRpcError() => $_has(2);
  @$pb.TagNumber(3)
  void clearRpcError() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get pong => $_getSZ(3);
  @$pb.TagNumber(4)
  set pong($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPong() => $_has(3);
  @$pb.TagNumber(4)
  void clearPong() => clearField(4);
}

class AddressStatusStreamReply extends $pb.GeneratedMessage {
  factory AddressStatusStreamReply({
    $core.String? address,
    $core.String? status,
    $core.String? rpcError,
    $core.String? pong,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (status != null) {
      $result.status = status;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    if (pong != null) {
      $result.pong = pong;
    }
    return $result;
  }
  AddressStatusStreamReply._() : super();
  factory AddressStatusStreamReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressStatusStreamReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressStatusStreamReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'rpcError')
    ..aOS(4, _omitFieldNames ? '' : 'pong')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressStatusStreamReply clone() => AddressStatusStreamReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressStatusStreamReply copyWith(void Function(AddressStatusStreamReply) updates) => super.copyWith((message) => updates(message as AddressStatusStreamReply)) as AddressStatusStreamReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressStatusStreamReply create() => AddressStatusStreamReply._();
  AddressStatusStreamReply createEmptyInstance() => create();
  static $pb.PbList<AddressStatusStreamReply> createRepeated() => $pb.PbList<AddressStatusStreamReply>();
  @$core.pragma('dart2js:noInline')
  static AddressStatusStreamReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressStatusStreamReply>(create);
  static AddressStatusStreamReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rpcError => $_getSZ(2);
  @$pb.TagNumber(3)
  set rpcError($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRpcError() => $_has(2);
  @$pb.TagNumber(3)
  void clearRpcError() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get pong => $_getSZ(3);
  @$pb.TagNumber(4)
  set pong($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPong() => $_has(3);
  @$pb.TagNumber(4)
  void clearPong() => clearField(4);
}

class AddressScanStreamReply extends $pb.GeneratedMessage {
  factory AddressScanStreamReply({
    $core.String? address,
    $core.bool? isKnown,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (isKnown != null) {
      $result.isKnown = isKnown;
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressScanStreamReply._() : super();
  factory AddressScanStreamReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressScanStreamReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressScanStreamReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOB(2, _omitFieldNames ? '' : 'isKnown')
    ..aOS(3, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressScanStreamReply clone() => AddressScanStreamReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressScanStreamReply copyWith(void Function(AddressScanStreamReply) updates) => super.copyWith((message) => updates(message as AddressScanStreamReply)) as AddressScanStreamReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressScanStreamReply create() => AddressScanStreamReply._();
  AddressScanStreamReply createEmptyInstance() => create();
  static $pb.PbList<AddressScanStreamReply> createRepeated() => $pb.PbList<AddressScanStreamReply>();
  @$core.pragma('dart2js:noInline')
  static AddressScanStreamReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressScanStreamReply>(create);
  static AddressScanStreamReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isKnown => $_getBF(1);
  @$pb.TagNumber(2)
  set isKnown($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsKnown() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsKnown() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rpcError => $_getSZ(2);
  @$pb.TagNumber(3)
  set rpcError($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRpcError() => $_has(2);
  @$pb.TagNumber(3)
  void clearRpcError() => clearField(3);
}

class AddressUtxosStreamReply extends $pb.GeneratedMessage {
  factory AddressUtxosStreamReply({
    $core.String? address,
    $core.Iterable<$core.String>? utxos,
    $core.String? rpcError,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (utxos != null) {
      $result.utxos.addAll(utxos);
    }
    if (rpcError != null) {
      $result.rpcError = rpcError;
    }
    return $result;
  }
  AddressUtxosStreamReply._() : super();
  factory AddressUtxosStreamReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressUtxosStreamReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressUtxosStreamReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'marisma'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..pPS(2, _omitFieldNames ? '' : 'utxos')
    ..aOS(3, _omitFieldNames ? '' : 'rpcError')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressUtxosStreamReply clone() => AddressUtxosStreamReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressUtxosStreamReply copyWith(void Function(AddressUtxosStreamReply) updates) => super.copyWith((message) => updates(message as AddressUtxosStreamReply)) as AddressUtxosStreamReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressUtxosStreamReply create() => AddressUtxosStreamReply._();
  AddressUtxosStreamReply createEmptyInstance() => create();
  static $pb.PbList<AddressUtxosStreamReply> createRepeated() => $pb.PbList<AddressUtxosStreamReply>();
  @$core.pragma('dart2js:noInline')
  static AddressUtxosStreamReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressUtxosStreamReply>(create);
  static AddressUtxosStreamReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get utxos => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get rpcError => $_getSZ(2);
  @$pb.TagNumber(3)
  set rpcError($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRpcError() => $_has(2);
  @$pb.TagNumber(3)
  void clearRpcError() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
