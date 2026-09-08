import '../../../../core/data/data_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/hotel_service.dart';
import '../../domain/entities/service_order.dart';
import '../models/stay_services_models.dart';
import 'stay_services_data_source.dart';

/// API-backed stay-services source.
///
/// Kept a documented stub for Mobile Phase 8 (same pattern as
/// `ApiPaymentDataSource`). Endpoints exist —
/// `GET /api/v1/hotels/{hotel}/service-categories`,
/// `GET /api/v1/hotels/{hotel}/services`,
/// `GET|POST /api/v1/reservations/{reservation}/service-orders`,
/// `GET /api/v1/reservations/{reservation}/service-orders/{serviceOrder}`,
/// `POST .../service-orders/{serviceOrder}/transition` — but all are
/// **staff/dashboard-scoped**:
///
/// * the catalogue endpoints require `auth:sanctum` staff tokens + hotel access
///   via `HotelServicePolicy` / `ServiceCategoryPolicy`;
/// * `POST .../service-orders` resolves the reservation through
///   `ReservationService::findAccessibleBy($request->user(), …)` and authorises
///   with `ServiceOrderPolicy`;
/// * cancellation is `POST .../transition` — a staff-only state-machine
///   operation; there is no guest cancel endpoint.
///
/// No guest-facing stay-services contract is approved. Also missing from
/// `ServiceResource`: an `estimated_minutes` field (documented gap). Wiring is
/// sketched in comments; until then each method raises
/// [NotImplementedInPhaseException].
class ApiStayServicesDataSource
    implements StayServicesDataSource, RemoteDataSource {
  ApiStayServicesDataSource(this._client);

  // Retained so wiring approved endpoints stays a small change.
  // ignore: unused_field
  final ApiClient _client;

  static const String _reason =
      'A guest-facing stay-services contract (guest identity + a guest cancel '
      'endpoint) is not approved yet';

  @override
  Future<ServiceCatalogue> fetchCatalogue(String hotelId) async {
    // final categories = await _client.getJson('/hotels/$hotelId/service-categories');
    // final services = await _client.getJson('/hotels/$hotelId/services');
    // return ServiceCatalogue(
    //   categories: [...map ServiceCategoryModel.fromJson().toEntity()],
    //   services: [...map HotelServiceModel.fromJson().toEntity()],
    // );
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<List<ServiceOrderModel>> fetchOrders(String reservationId) async {
    // final json = await _client.getJson('/reservations/$reservationId/service-orders');
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<ServiceOrderModel> fetchOrder(
      String reservationId, String orderId) async {
    // final json = await _client.getJson(
    //   '/reservations/$reservationId/service-orders/$orderId');
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<ServiceOrderModel> createOrder(CreateServiceRequest request) async {
    // final body = ServiceOrderCreatePayload.fromRequest(request).toJson();
    // final json = await _client.postJson(
    //   '/reservations/${request.reservationId}/service-orders', body: body);
    throw const NotImplementedInPhaseException(_reason);
  }

  @override
  Future<ServiceOrderModel> cancelOrder(
      String reservationId, String orderId) async {
    // No guest cancel endpoint — cancellation is a staff `transition` call.
    throw const NotImplementedInPhaseException(_reason);
  }
}
