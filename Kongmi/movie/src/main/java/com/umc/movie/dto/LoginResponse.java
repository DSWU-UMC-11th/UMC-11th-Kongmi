package com.umc.movie.dto;

public record LoginResponse(
        String nickname,
        String accessToken
) {}
