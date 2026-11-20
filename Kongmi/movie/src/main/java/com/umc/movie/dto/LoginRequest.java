package com.umc.movie.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @Schema(description = "가입할 때 사용한 이메일", example = "challenger@umc.com")
        @NotBlank(message = "이메일을 입력해주세요.")
        @Email(message = "이메일 형식이 올바르지 않습니다.")
        String email,

        @Schema(description = "가입할 때 사용한 비밀번호", example = "Umc1234!")
        @NotBlank(message = "비밀번호를 입력해주세요.")
        String password
) {}