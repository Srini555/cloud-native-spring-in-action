package com.polarbookshop.orderservice.order.web;

import javax.validation.Valid;

import com.polarbookshop.orderservice.order.domain.Order;
import com.polarbookshop.orderservice.order.domain.OrderService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("orders")
@RequiredArgsConstructor
public class OrderController {
	private static final Logger log = LoggerFactory.getLogger(OrderController.class);
	private final OrderService orderService;

	@GetMapping
	public Flux<Order> getAllOrders(@AuthenticationPrincipal Jwt jwt) {
		log.info("Fetching all the book orders for {}", jwt.getSubject());
		return orderService.getAllOrders(jwt.getSubject());
	}

	@PostMapping
	public Mono<Order> submitOrder(@RequestBody @Valid OrderRequest orderRequest) {
		log.info("Submitting a new order for book with ISBN {}", orderRequest.getIsbn());
		return orderService.submitOrder(orderRequest.getIsbn(), orderRequest.getQuantity());
	}

}
