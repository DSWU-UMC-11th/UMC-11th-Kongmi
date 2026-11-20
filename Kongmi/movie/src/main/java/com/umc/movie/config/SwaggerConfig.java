// src/main/java/com/umc/movie/config/SwaggerConfig.java
package com.umc.movie.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    // 각 API에 @SecurityRequirement(name = "bearerAuth")로 연결할 때 쓰는 이름입니다.
    public static final String BEARER_AUTH = "bearerAuth";

    @Bean
    public OpenAPI movieOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("영화 평점 서비스 API")
                        .description("UMC 11기 백엔드 워크북에서 만든 회원/평점/즐겨찾기 API 문서입니다.")
                        .version("v1"))
                // 자물쇠 버튼(Authorize)에 쓸 인증 방식을 등록합니다.
                // 여기서는 "이런 인증 방식이 있다"고 선언만 하고,
                // 실제로 어떤 API에 필요한지는 각 컨트롤러 메서드에서 지정합니다.
                .components(new Components()
                        .addSecuritySchemes(BEARER_AUTH, new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP) // Authorization 헤더를 사용하는 방식
                                .scheme("bearer")               // "Bearer {토큰}" 형태
                                .bearerFormat("JWT")));         // 문서에 표시할 토큰 종류
    }
}