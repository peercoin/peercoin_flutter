//
//  Generated code. Do not modify.
//  source: marisma.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'marisma.pb.dart' as $0;

export 'marisma.pb.dart';

@$pb.GrpcServiceName('marisma.Marisma')
class MarismaClient extends $grpc.Client {
  static final _$getBlockHeight = $grpc.ClientMethod<$0.EmptyRequest, $0.BlockHeightReply>(
      '/marisma.Marisma/GetBlockHeight',
      ($0.EmptyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BlockHeightReply.fromBuffer(value));
  static final _$getAdressBalance = $grpc.ClientMethod<$0.AddressRequest, $0.AddressBalanceReply>(
      '/marisma.Marisma/GetAdressBalance',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressBalanceReply.fromBuffer(value));
  static final _$getAddressUtxoList = $grpc.ClientMethod<$0.AddressListRequest, $0.AddressUtxoListReply>(
      '/marisma.Marisma/GetAddressUtxoList',
      ($0.AddressListRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressUtxoListReply.fromBuffer(value));
  static final _$getAddressHasUtxos = $grpc.ClientMethod<$0.AddressRequest, $0.AddressHasUtxosReply>(
      '/marisma.Marisma/GetAddressHasUtxos',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressHasUtxosReply.fromBuffer(value));
  static final _$getAddressIsKnown = $grpc.ClientMethod<$0.AddressRequest, $0.AddressIsKnownReply>(
      '/marisma.Marisma/GetAddressIsKnown',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressIsKnownReply.fromBuffer(value));
  static final _$getAddressNumberOfUtxos = $grpc.ClientMethod<$0.AddressRequest, $0.AddressNumberOfUtxosReply>(
      '/marisma.Marisma/GetAddressNumberOfUtxos',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressNumberOfUtxosReply.fromBuffer(value));
  static final _$getAddressUtxoHistoryList = $grpc.ClientMethod<$0.AddressListRequest, $0.AddressUtxoHistoryReply>(
      '/marisma.Marisma/GetAddressUtxoHistoryList',
      ($0.AddressListRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressUtxoHistoryReply.fromBuffer(value));
  static final _$getTransaction = $grpc.ClientMethod<$0.TxRequest, $0.TxReply>(
      '/marisma.Marisma/GetTransaction',
      ($0.TxRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TxReply.fromBuffer(value));
  static final _$getEstimateFeePerKb = $grpc.ClientMethod<$0.EstimateFeeRequest, $0.EstimateFeeReply>(
      '/marisma.Marisma/GetEstimateFeePerKb',
      ($0.EstimateFeeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.EstimateFeeReply.fromBuffer(value));
  static final _$broadCastTransaction = $grpc.ClientMethod<$0.BroadCastTransactionRequest, $0.BroadCastTransactionReply>(
      '/marisma.Marisma/BroadCastTransaction',
      ($0.BroadCastTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BroadCastTransactionReply.fromBuffer(value));
  static final _$blockHashStream = $grpc.ClientMethod<$0.BlockHashStreamRequest, $0.BlockHashStreamReply>(
      '/marisma.Marisma/BlockHashStream',
      ($0.BlockHashStreamRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BlockHashStreamReply.fromBuffer(value));
  static final _$addressStatusStream = $grpc.ClientMethod<$0.AddressRequest, $0.AddressStatusStreamReply>(
      '/marisma.Marisma/AddressStatusStream',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressStatusStreamReply.fromBuffer(value));
  static final _$addressScanStream = $grpc.ClientMethod<$0.AddressRequest, $0.AddressScanStreamReply>(
      '/marisma.Marisma/AddressScanStream',
      ($0.AddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressScanStreamReply.fromBuffer(value));
  static final _$addressUtxosStream = $grpc.ClientMethod<$0.AddressListRequest, $0.AddressUtxosStreamReply>(
      '/marisma.Marisma/AddressUtxosStream',
      ($0.AddressListRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddressUtxosStreamReply.fromBuffer(value));

  MarismaClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.BlockHeightReply> getBlockHeight($0.EmptyRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockHeight, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressBalanceReply> getAdressBalance($0.AddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAdressBalance, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressUtxoListReply> getAddressUtxoList($0.AddressListRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressUtxoList, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressHasUtxosReply> getAddressHasUtxos($0.AddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressHasUtxos, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressIsKnownReply> getAddressIsKnown($0.AddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressIsKnown, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos($0.AddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressNumberOfUtxos, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressUtxoHistoryReply> getAddressUtxoHistoryList($0.AddressListRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressUtxoHistoryList, request, options: options);
  }

  $grpc.ResponseFuture<$0.TxReply> getTransaction($0.TxRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.EstimateFeeReply> getEstimateFeePerKb($0.EstimateFeeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getEstimateFeePerKb, request, options: options);
  }

  $grpc.ResponseFuture<$0.BroadCastTransactionReply> broadCastTransaction($0.BroadCastTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadCastTransaction, request, options: options);
  }

  $grpc.ResponseStream<$0.BlockHashStreamReply> blockHashStream($0.BlockHashStreamRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$blockHashStream, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.AddressStatusStreamReply> addressStatusStream($async.Stream<$0.AddressRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$addressStatusStream, request, options: options);
  }

  $grpc.ResponseStream<$0.AddressScanStreamReply> addressScanStream($async.Stream<$0.AddressRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$addressScanStream, request, options: options);
  }

  $grpc.ResponseStream<$0.AddressUtxosStreamReply> addressUtxosStream($async.Stream<$0.AddressListRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$addressUtxosStream, request, options: options);
  }
}

@$pb.GrpcServiceName('marisma.Marisma')
abstract class MarismaServiceBase extends $grpc.Service {
  $core.String get $name => 'marisma.Marisma';

  MarismaServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EmptyRequest, $0.BlockHeightReply>(
        'GetBlockHeight',
        getBlockHeight_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EmptyRequest.fromBuffer(value),
        ($0.BlockHeightReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressBalanceReply>(
        'GetAdressBalance',
        getAdressBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressBalanceReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressListRequest, $0.AddressUtxoListReply>(
        'GetAddressUtxoList',
        getAddressUtxoList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressListRequest.fromBuffer(value),
        ($0.AddressUtxoListReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressHasUtxosReply>(
        'GetAddressHasUtxos',
        getAddressHasUtxos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressHasUtxosReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressIsKnownReply>(
        'GetAddressIsKnown',
        getAddressIsKnown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressIsKnownReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressNumberOfUtxosReply>(
        'GetAddressNumberOfUtxos',
        getAddressNumberOfUtxos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressNumberOfUtxosReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressListRequest, $0.AddressUtxoHistoryReply>(
        'GetAddressUtxoHistoryList',
        getAddressUtxoHistoryList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressListRequest.fromBuffer(value),
        ($0.AddressUtxoHistoryReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TxRequest, $0.TxReply>(
        'GetTransaction',
        getTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TxRequest.fromBuffer(value),
        ($0.TxReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EstimateFeeRequest, $0.EstimateFeeReply>(
        'GetEstimateFeePerKb',
        getEstimateFeePerKb_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EstimateFeeRequest.fromBuffer(value),
        ($0.EstimateFeeReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BroadCastTransactionRequest, $0.BroadCastTransactionReply>(
        'BroadCastTransaction',
        broadCastTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BroadCastTransactionRequest.fromBuffer(value),
        ($0.BroadCastTransactionReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockHashStreamRequest, $0.BlockHashStreamReply>(
        'BlockHashStream',
        blockHashStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.BlockHashStreamRequest.fromBuffer(value),
        ($0.BlockHashStreamReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressStatusStreamReply>(
        'AddressStatusStream',
        addressStatusStream,
        true,
        true,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressStatusStreamReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressScanStreamReply>(
        'AddressScanStream',
        addressScanStream,
        true,
        true,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressScanStreamReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressListRequest, $0.AddressUtxosStreamReply>(
        'AddressUtxosStream',
        addressUtxosStream,
        true,
        true,
        ($core.List<$core.int> value) => $0.AddressListRequest.fromBuffer(value),
        ($0.AddressUtxosStreamReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.BlockHeightReply> getBlockHeight_Pre($grpc.ServiceCall call, $async.Future<$0.EmptyRequest> request) async {
    return getBlockHeight(call, await request);
  }

  $async.Future<$0.AddressBalanceReply> getAdressBalance_Pre($grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAdressBalance(call, await request);
  }

  $async.Future<$0.AddressUtxoListReply> getAddressUtxoList_Pre($grpc.ServiceCall call, $async.Future<$0.AddressListRequest> request) async {
    return getAddressUtxoList(call, await request);
  }

  $async.Future<$0.AddressHasUtxosReply> getAddressHasUtxos_Pre($grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressHasUtxos(call, await request);
  }

  $async.Future<$0.AddressIsKnownReply> getAddressIsKnown_Pre($grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressIsKnown(call, await request);
  }

  $async.Future<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos_Pre($grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressNumberOfUtxos(call, await request);
  }

  $async.Future<$0.AddressUtxoHistoryReply> getAddressUtxoHistoryList_Pre($grpc.ServiceCall call, $async.Future<$0.AddressListRequest> request) async {
    return getAddressUtxoHistoryList(call, await request);
  }

  $async.Future<$0.TxReply> getTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.TxRequest> request) async {
    return getTransaction(call, await request);
  }

  $async.Future<$0.EstimateFeeReply> getEstimateFeePerKb_Pre($grpc.ServiceCall call, $async.Future<$0.EstimateFeeRequest> request) async {
    return getEstimateFeePerKb(call, await request);
  }

  $async.Future<$0.BroadCastTransactionReply> broadCastTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.BroadCastTransactionRequest> request) async {
    return broadCastTransaction(call, await request);
  }

  $async.Stream<$0.BlockHashStreamReply> blockHashStream_Pre($grpc.ServiceCall call, $async.Future<$0.BlockHashStreamRequest> request) async* {
    yield* blockHashStream(call, await request);
  }

  $async.Future<$0.BlockHeightReply> getBlockHeight($grpc.ServiceCall call, $0.EmptyRequest request);
  $async.Future<$0.AddressBalanceReply> getAdressBalance($grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressUtxoListReply> getAddressUtxoList($grpc.ServiceCall call, $0.AddressListRequest request);
  $async.Future<$0.AddressHasUtxosReply> getAddressHasUtxos($grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressIsKnownReply> getAddressIsKnown($grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos($grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressUtxoHistoryReply> getAddressUtxoHistoryList($grpc.ServiceCall call, $0.AddressListRequest request);
  $async.Future<$0.TxReply> getTransaction($grpc.ServiceCall call, $0.TxRequest request);
  $async.Future<$0.EstimateFeeReply> getEstimateFeePerKb($grpc.ServiceCall call, $0.EstimateFeeRequest request);
  $async.Future<$0.BroadCastTransactionReply> broadCastTransaction($grpc.ServiceCall call, $0.BroadCastTransactionRequest request);
  $async.Stream<$0.BlockHashStreamReply> blockHashStream($grpc.ServiceCall call, $0.BlockHashStreamRequest request);
  $async.Stream<$0.AddressStatusStreamReply> addressStatusStream($grpc.ServiceCall call, $async.Stream<$0.AddressRequest> request);
  $async.Stream<$0.AddressScanStreamReply> addressScanStream($grpc.ServiceCall call, $async.Stream<$0.AddressRequest> request);
  $async.Stream<$0.AddressUtxosStreamReply> addressUtxosStream($grpc.ServiceCall call, $async.Stream<$0.AddressListRequest> request);
}
