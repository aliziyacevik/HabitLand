# ISSUE-005

## Title
Daily wisdom still references social features that are disabled

## Category
Product / Stale Reference

## Severity
Medium

## Priority
P2

## Screen / Feature
Home Dashboard → Daily Wisdom section

## Suspected Root Cause
`HomeDashboardView.swift:1354` — wisdom array contains "Social Accountability" tip: "People who share their goals with friends are 65% more likely to achieve them." But social features are disabled/removed.

## Recommended Fix
Remove the social accountability tip from the wisdom array, or replace with a non-social motivational tip.
