package com.polarbookshop.orderservice.order.domain;

import java.util.Objects;

import com.polarbookshop.orderservice.order.persistence.DataConfig;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;
import reactor.test.StepVerifier;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.r2dbc.DataR2dbcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

@DataR2dbcTest
@Import(DataConfig.class)
@Testcontainers
class OrderRepositoryR2dbcTests {

    @Container
    static PostgreSQLContainer<?> postgresql = new PostgreSQLContainer<>(DockerImageName.parse("postgres:13"));

    @Autowired
    private OrderRepository orderRepository;

    @DynamicPropertySource
    static void postgresqlProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.r2dbc.url", OrderRepositoryR2dbcTests::r2dbcUrl);
        registry.add("spring.r2dbc.username", postgresql::getUsername);
        registry.add("spring.r2dbc.password", postgresql::getPassword);

        registry.add("spring.flyway.url", postgresql::getJdbcUrl);
        registry.add("spring.flyway.user", postgresql::getUsername);
        registry.add("spring.flyway.password", postgresql::getPassword);
    }

    private static String r2dbcUrl() {
        return String.format("r2dbc:postgresql://%s:%s/%s", postgresql.getHost(),
                postgresql.getFirstMappedPort(), postgresql.getDatabaseName());
    }

    @Test
    void findOrderByIdWhenNotExisting() {
        StepVerifier.create(orderRepository.findById(394L))
                .expectNextCount(0)
                .verifyComplete();
    }

    @Test
    void createRejectedOrder() {
        Order rejectedOrder = new Order("1234567890", 3, OrderStatus.REJECTED);
        StepVerifier.create(orderRepository.save(rejectedOrder))
                .expectNextMatches(order -> order.getStatus().equals(OrderStatus.REJECTED))
                .verifyComplete();
    }

    @Test
    void createOrderNotAuthenticated() {
        Order rejectedOrder = new Order("1234567890", 3, OrderStatus.REJECTED);
        StepVerifier.create(orderRepository.save(rejectedOrder))
                .expectNextMatches(order -> Objects.isNull(order.getCreatedBy()) &&
                        Objects.isNull(order.getLastModifiedBy()))
                .verifyComplete();
    }

    @Test
    @WithMockUser("melinda")
    void createOrderWhenAuthenticated() {
        Order rejectedOrder = new Order("1234567890", 3, OrderStatus.REJECTED);
        StepVerifier.create(orderRepository.save(rejectedOrder))
                .expectNextMatches(order -> order.getCreatedBy().equals("melinda") &&
                        order.getLastModifiedBy().equals("melinda"))
                .verifyComplete();
    }

}