<?php

namespace App\Domain\Review\Exceptions;

use RuntimeException;

/**
 * Thrown when a review cannot be submitted. `$reason` is a short, fixed
 * machine code — never a secret or an internal detail (same convention as
 * LoyaltyNotAllowedException).
 */
class ReviewNotAllowedException extends RuntimeException
{
    public function __construct(public readonly string $reason)
    {
        parent::__construct("This review action is not allowed ({$reason}).");
    }

    public static function reservationNotCompleted(string $status): self
    {
        return new self("reservation_not_completed:{$status}");
    }
}
