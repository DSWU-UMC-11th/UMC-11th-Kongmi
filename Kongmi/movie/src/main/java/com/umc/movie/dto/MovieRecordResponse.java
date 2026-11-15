package com.umc.movie.dto;

public record MovieRecordResponse(
        RatingResponse rating,
        FavoriteResponse favorite
) {}
