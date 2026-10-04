package com.umc.study.service;

import com.umc.study.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;

    public List<Map<String, Object>> getAllBooks() {
        return bookRepository.findAll();
    }

    public void createBook(Map<String, Object> body) {
        bookRepository.save(body);
    }
}