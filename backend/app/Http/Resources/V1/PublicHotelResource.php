<?php

namespace App\Http\Resources\V1;

use App\Domain\HotelGroup\Models\Hotel;
use App\Support\LocalizedContent;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Hotel
 *
 * Anonymous guest view of a hotel (Slice 1 + booking discovery enrichment).
 * Deliberately narrower than the staff HotelResource: no `hotel_group_id`,
 * no `is_active` (always true here), no raw i18n maps.
 *
 * `name` / `tagline` / `description` are resolved to the request locale
 * (`X-Locale` header / `?lang` / `Accept-Language`, see SetLocale) with a
 * fallback to the legacy `name` string — never a fabricated translation.
 *
 * `room_types` is present only when the relation is loaded (detail
 * endpoint); `price_from` / `room_types_count` only when the list query
 * aggregated them; `gallery` only when eager-loaded (detail).
 */
class PublicHotelResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => LocalizedContent::resolve($this->name_i18n, $this->name),
            'tagline' => LocalizedContent::resolve($this->tagline_i18n),
            'description' => LocalizedContent::resolve($this->description_i18n),
            'slug' => $this->slug,
            'city' => $this->city,
            'country' => $this->country,
            'country_id' => $this->country_id,
            'city_id' => $this->city_id,
            'timezone' => $this->timezone,
            'star_rating' => $this->star_rating,
            // Contract-stable: still a plain array of facility keys (e.g.
            // "free_wifi"), now sourced from the `facilities` relation
            // instead of the old free-text JSON column — no guest/mobile
            // consumer needs to change.
            'amenities' => $this->whenLoaded('facilities', fn () => $this->facilities->pluck('key')->values(), []),
            'logo_url' => $this->whenLoaded('logo', fn () => $this->logo?->url()),
            'cover_url' => $this->whenLoaded('cover', fn () => $this->cover?->url()),
            'gallery' => HotelMediaResource::collection($this->whenLoaded('galleryMedia')),
            'meta_title' => LocalizedContent::resolve($this->meta_title_i18n),
            'meta_description' => LocalizedContent::resolve($this->meta_description_i18n),
            'seo_indexable' => $this->seo_indexable,
            'price_from' => $this->when(
                $this->price_from !== null,
                fn () => number_format((float) $this->price_from, 2, '.', ''),
            ),
            'room_types_count' => $this->whenNotNull($this->room_types_count ?? null),
            // Authoritative rating: the average `rating` of this hotel's
            // `published` reviews only (never pending/rejected) — see
            // Review::STATUS_PUBLISHED. Present only when the aggregate was
            // actually loaded (list/detail queries), same convention as
            // `price_from` above. Never the raw booking count used to order
            // "recommended" — that stays internal to the sort query.
            'rating' => $this->when(
                ($this->avg_rating ?? null) !== null,
                fn () => number_format((float) $this->avg_rating, 2, '.', ''),
            ),
            'reviews_count' => $this->whenNotNull($this->reviews_count ?? null),
            'room_types' => PublicRoomTypeResource::collection($this->whenLoaded('roomTypes')),
        ];
    }
}
