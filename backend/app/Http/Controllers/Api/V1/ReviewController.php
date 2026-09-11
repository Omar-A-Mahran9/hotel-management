<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\HotelGroup\Models\Hotel;
use App\Domain\Review\Models\Review;
use App\Domain\Review\Services\ReviewService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Review\ModerateReviewRequest;
use App\Http\Resources\V1\ReviewResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Staff-facing review listing (every moderation state) + moderation
 * decision. Separate from the guest surface — a guest never reaches this
 * controller (GuestReviewController is the only guest-facing entry point).
 */
class ReviewController extends Controller
{
    public function __construct(private readonly ReviewService $reviews) {}

    public function index(Request $request, int $hotel): JsonResponse
    {
        $found = Hotel::query()->find($hotel);

        if (! $found) {
            abort(404);
        }

        $this->authorize('view', [Review::class, $found]);

        $status = $request->query('status');

        $reviews = $this->reviews->allForHotel(
            $found->id,
            is_string($status) ? $status : null,
            (int) $request->query('per_page', 15),
        );

        return $this->success(ReviewResource::collection($reviews), __('api.reviews.list'));
    }

    public function moderate(ModerateReviewRequest $request, int $review): JsonResponse
    {
        $found = Review::query()->find($review);

        if (! $found) {
            abort(404);
        }

        $this->authorize('moderate', $found);

        $updated = $this->reviews->moderate($found, $request->decision(), $request->user());

        return $this->success(
            new ReviewResource($updated),
            __('api.reviews.'.$updated->status),
        );
    }
}
