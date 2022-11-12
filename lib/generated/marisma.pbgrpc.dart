///
//  Generated code. Do not modify.
//  source: marisma.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'marisma.pb.dart' as $0;
export 'marisma.pb.dart';

class MarismaClient extends $grpc.Client {
  static final _$getBlockHeight =
      $grpc.ClientMethod<$0.BlockHeightRequest, $0.BlockHeightReply>(
          '/marisma.Marisma/GetBlockHeight',
          ($0.BlockHeightRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.BlockHeightReply.fromBuffer(value));
  static final _$getAdressBalance =
      $grpc.ClientMethod<$0.AddressRequest, $0.AddressBalanceReply>(
          '/marisma.Marisma/GetAdressBalance',
          ($0.AddressRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressBalanceReply.fromBuffer(value));
  static final _$getAddressUtxoList =
      $grpc.ClientMethod<$0.AddressListRequest, $0.AddressUtxoListReply>(
          '/marisma.Marisma/GetAddressUtxoList',
          ($0.AddressListRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressUtxoListReply.fromBuffer(value));
  static final _$getAddressHasUtxos =
      $grpc.ClientMethod<$0.AddressRequest, $0.AddressHasUtxosReply>(
          '/marisma.Marisma/GetAddressHasUtxos',
          ($0.AddressRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressHasUtxosReply.fromBuffer(value));
  static final _$getAddressIsKnown =
      $grpc.ClientMethod<$0.AddressRequest, $0.AddressIsKnownReply>(
          '/marisma.Marisma/GetAddressIsKnown',
          ($0.AddressRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressIsKnownReply.fromBuffer(value));
  static final _$getAddressNumberOfUtxos =
      $grpc.ClientMethod<$0.AddressRequest, $0.AddressNumberOfUtxosReply>(
          '/marisma.Marisma/GetAddressNumberOfUtxos',
          ($0.AddressRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressNumberOfUtxosReply.fromBuffer(value));
  static final _$getAddressHistory =
      $grpc.ClientMethod<$0.AddressListRequest, $0.AddressHistoryReply>(
          '/marisma.Marisma/GetAddressHistory',
          ($0.AddressListRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AddressHistoryReply.fromBuffer(value));
  static final _$getTransaction = $grpc.ClientMethod<$0.TxRequest, $0.TxReply>(
      '/marisma.Marisma/GetTransaction',
      ($0.TxRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TxReply.fromBuffer(value));
  static final _$getEstimateFeePerKb =
      $grpc.ClientMethod<$0.EstimateFeeRequest, $0.EstimateFeeReply>(
          '/marisma.Marisma/GetEstimateFeePerKb',
          ($0.EstimateFeeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.EstimateFeeReply.fromBuffer(value));
  static final _$broadCastTransaction = $grpc.ClientMethod<
          $0.BroadCastTransactionRequest, $0.BroadCastTransactionReply>(
      '/marisma.Marisma/BroadCastTransaction',
      ($0.BroadCastTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.BroadCastTransactionReply.fromBuffer(value));
  static final _$subscribeTestStream =
      $grpc.ClientMethod<$0.TestStreamRequest, $0.TestStreamReply>(
          '/marisma.Marisma/SubscribeTestStream',
          ($0.TestStreamRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.TestStreamReply.fromBuffer(value));

  MarismaClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.BlockHeightReply> getBlockHeight(
      $0.BlockHeightRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockHeight, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressBalanceReply> getAdressBalance(
      $0.AddressRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAdressBalance, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressUtxoListReply> getAddressUtxoList(
      $0.AddressListRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressUtxoList, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressHasUtxosReply> getAddressHasUtxos(
      $0.AddressRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressHasUtxos, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressIsKnownReply> getAddressIsKnown(
      $0.AddressRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressIsKnown, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos(
      $0.AddressRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressNumberOfUtxos, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.AddressHistoryReply> getAddressHistory(
      $0.AddressListRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAddressHistory, request, options: options);
  }

  $grpc.ResponseFuture<$0.TxReply> getTransaction($0.TxRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.EstimateFeeReply> getEstimateFeePerKb(
      $0.EstimateFeeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getEstimateFeePerKb, request, options: options);
  }

  $grpc.ResponseFuture<$0.BroadCastTransactionReply> broadCastTransaction(
      $0.BroadCastTransactionRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadCastTransaction, request, options: options);
  }

  $grpc.ResponseStream<$0.TestStreamReply> subscribeTestStream(
      $0.TestStreamRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$subscribeTestStream, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class MarismaServiceBase extends $grpc.Service {
  $core.String get $name => 'marisma.Marisma';

  MarismaServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.BlockHeightRequest, $0.BlockHeightReply>(
        'GetBlockHeight',
        getBlockHeight_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BlockHeightRequest.fromBuffer(value),
        ($0.BlockHeightReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddressRequest, $0.AddressBalanceReply>(
        'GetAdressBalance',
        getAdressBalance_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddressRequest.fromBuffer(value),
        ($0.AddressBalanceReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddressListRequest, $0.AddressUtxoListReply>(
            'GetAddressUtxoList',
            getAddressUtxoList_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddressListRequest.fromBuffer(value),
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
    $addMethod(
        $grpc.ServiceMethod<$0.AddressRequest, $0.AddressNumberOfUtxosReply>(
            'GetAddressNumberOfUtxos',
            getAddressNumberOfUtxos_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddressRequest.fromBuffer(value),
            ($0.AddressNumberOfUtxosReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddressListRequest, $0.AddressHistoryReply>(
            'GetAddressHistory',
            getAddressHistory_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddressListRequest.fromBuffer(value),
            ($0.AddressHistoryReply value) => value.writeToBuffer()));
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
        ($core.List<$core.int> value) =>
            $0.EstimateFeeRequest.fromBuffer(value),
        ($0.EstimateFeeReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BroadCastTransactionRequest,
            $0.BroadCastTransactionReply>(
        'BroadCastTransaction',
        broadCastTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BroadCastTransactionRequest.fromBuffer(value),
        ($0.BroadCastTransactionReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TestStreamRequest, $0.TestStreamReply>(
        'SubscribeTestStream',
        subscribeTestStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.TestStreamRequest.fromBuffer(value),
        ($0.TestStreamReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.BlockHeightReply> getBlockHeight_Pre($grpc.ServiceCall call,
      $async.Future<$0.BlockHeightRequest> request) async {
    return getBlockHeight(call, await request);
  }

  $async.Future<$0.AddressBalanceReply> getAdressBalance_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAdressBalance(call, await request);
  }

  $async.Future<$0.AddressUtxoListReply> getAddressUtxoList_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.AddressListRequest> request) async {
    return getAddressUtxoList(call, await request);
  }

  $async.Future<$0.AddressHasUtxosReply> getAddressHasUtxos_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressHasUtxos(call, await request);
  }

  $async.Future<$0.AddressIsKnownReply> getAddressIsKnown_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressIsKnown(call, await request);
  }

  $async.Future<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AddressRequest> request) async {
    return getAddressNumberOfUtxos(call, await request);
  }

  $async.Future<$0.AddressHistoryReply> getAddressHistory_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.AddressListRequest> request) async {
    return getAddressHistory(call, await request);
  }

  $async.Future<$0.TxReply> getTransaction_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TxRequest> request) async {
    return getTransaction(call, await request);
  }

  $async.Future<$0.EstimateFeeReply> getEstimateFeePerKb_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.EstimateFeeRequest> request) async {
    return getEstimateFeePerKb(call, await request);
  }

  $async.Future<$0.BroadCastTransactionReply> broadCastTransaction_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.BroadCastTransactionRequest> request) async {
    return broadCastTransaction(call, await request);
  }

  $async.Stream<$0.TestStreamReply> subscribeTestStream_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.TestStreamRequest> request) async* {
    yield* subscribeTestStream(call, await request);
  }

  $async.Future<$0.BlockHeightReply> getBlockHeight(
      $grpc.ServiceCall call, $0.BlockHeightRequest request);
  $async.Future<$0.AddressBalanceReply> getAdressBalance(
      $grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressUtxoListReply> getAddressUtxoList(
      $grpc.ServiceCall call, $0.AddressListRequest request);
  $async.Future<$0.AddressHasUtxosReply> getAddressHasUtxos(
      $grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressIsKnownReply> getAddressIsKnown(
      $grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressNumberOfUtxosReply> getAddressNumberOfUtxos(
      $grpc.ServiceCall call, $0.AddressRequest request);
  $async.Future<$0.AddressHistoryReply> getAddressHistory(
      $grpc.ServiceCall call, $0.AddressListRequest request);
  $async.Future<$0.TxReply> getTransaction(
      $grpc.ServiceCall call, $0.TxRequest request);
  $async.Future<$0.EstimateFeeReply> getEstimateFeePerKb(
      $grpc.ServiceCall call, $0.EstimateFeeRequest request);
  $async.Future<$0.BroadCastTransactionReply> broadCastTransaction(
      $grpc.ServiceCall call, $0.BroadCastTransactionRequest request);
  $async.Stream<$0.TestStreamReply> subscribeTestStream(
      $grpc.ServiceCall call, $0.TestStreamRequest request);
}
