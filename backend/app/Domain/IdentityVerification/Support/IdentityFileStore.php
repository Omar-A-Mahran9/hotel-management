<?php

namespace App\Domain\IdentityVerification\Support;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

/**
 * Phase 6 — the single place identity documents and selfies are written to
 * storage (Phase 0 §17, R38-R42).
 *
 * Hard rules enforced here:
 *  - the target disk comes from config('verification.storage.disk') and must
 *    NOT be the framework "public" disk — a public path for an ID image is
 *    rejected outright;
 *  - files are stored under a per-session prefix with a non-guessable-ish,
 *    attempt-scoped name;
 *  - only the relative storage path is ever returned to the domain — never a
 *    URL, never an absolute filesystem path.
 *
 * The approved §16 endpoint map has no document-download route, so nothing
 * in this phase ever reads these files back or builds a signed URL for them.
 */
final class IdentityFileStore
{
    public const KIND_DOCUMENT = 'document';

    public const KIND_SELFIE = 'selfie';

    public function disk(): string
    {
        $disk = (string) config('verification.storage.disk', 'local');

        if ($disk === 'public') {
            throw new RuntimeException('Identity verification files must never be stored on the public disk.');
        }

        return $disk;
    }

    /**
     * Persist one uploaded file for an attempt and return its private
     * relative storage path.
     *
     * The stored filename's extension is derived from the file's guessed
     * content type ($file->extension()), never from the client-supplied
     * name — a client cannot influence the extension of the persisted file.
     */
    public function store(int $sessionId, int $attemptId, string $kind, UploadedFile $file): string
    {
        $extension = strtolower($file->extension() ?: 'bin');

        $path = $file->storeAs(
            "identity-verification/{$sessionId}",
            "{$attemptId}-{$kind}.{$extension}",
            ['disk' => $this->disk()],
        );

        if ($path === false) {
            throw new RuntimeException('Failed to store the identity verification file.');
        }

        return $path;
    }

    /**
     * Remove a previously stored file (used when a document is re-uploaded
     * onto the same pending attempt).
     */
    public function delete(?string $path): void
    {
        if ($path === null || $path === '') {
            return;
        }

        Storage::disk($this->disk())->delete($path);
    }
}
