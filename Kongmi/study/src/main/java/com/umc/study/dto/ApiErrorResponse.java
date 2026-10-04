package com.umc.study.dto;

public record ApiErrorResponse(
        int status,
        String message
) {}