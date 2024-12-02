//
//  Generated code. Do not modify.
//  source: ricart_agrawala.proto
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

import 'ricart_agrawala.pb.dart' as $0;

export 'ricart_agrawala.pb.dart';

@$pb.GrpcServiceName('RicartAgrawala')
class RicartAgrawalaClient extends $grpc.Client {
  static final _$requestAccess = $grpc.ClientMethod<$0.Request, $0.Response>(
      '/RicartAgrawala/RequestAccess',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Response.fromBuffer(value));
  static final _$releaseAccess = $grpc.ClientMethod<$0.Request, $0.Response>(
      '/RicartAgrawala/ReleaseAccess',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Response.fromBuffer(value));

  RicartAgrawalaClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Response> requestAccess($0.Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$requestAccess, request, options: options);
  }

  $grpc.ResponseFuture<$0.Response> releaseAccess($0.Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$releaseAccess, request, options: options);
  }
}

@$pb.GrpcServiceName('RicartAgrawala')
abstract class RicartAgrawalaServiceBase extends $grpc.Service {
  $core.String get $name => 'RicartAgrawala';

  RicartAgrawalaServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Response>(
        'RequestAccess',
        requestAccess_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Response value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Response>(
        'ReleaseAccess',
        releaseAccess_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Response value) => value.writeToBuffer()));
  }

  $async.Future<$0.Response> requestAccess_Pre($grpc.ServiceCall call, $async.Future<$0.Request> request) async {
    return requestAccess(call, await request);
  }

  $async.Future<$0.Response> releaseAccess_Pre($grpc.ServiceCall call, $async.Future<$0.Request> request) async {
    return releaseAccess(call, await request);
  }

  $async.Future<$0.Response> requestAccess($grpc.ServiceCall call, $0.Request request);
  $async.Future<$0.Response> releaseAccess($grpc.ServiceCall call, $0.Request request);
}
